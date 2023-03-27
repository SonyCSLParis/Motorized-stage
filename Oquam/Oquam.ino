/*
  romi-rover

  Copyright (C) 2019 Sony Computer Science Laboratories
  Author(s) Peter Hanappe

  romi-rover is collection of applications for the Romi Rover.

  romi-rover is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see
  <http://www.gnu.org/licenses/>.

 */
#include "block.h"
#include "stepper.h"
#include "config.h"
#include <ArduinoSerial.h>
#include <RomiSerial.h>

using namespace romiserial;
/**
 *  \brief The possible states of the controller (the main thread).
 */
enum {
        STATE_RUNNING = 'r',
        STATE_PAUSED = 'p',
        STATE_HOMING = 'h',
        STATE_ERROR = 'e'
};

extern volatile block_t *current_block;

uint8_t controller_state;

static const char *kInvalidState = "Invalid state";

void handle_moveto(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_move(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_moveat(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_pause(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_continue(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_reset(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void send_position(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void send_idle(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_homing(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_set_homing(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_enable(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_spindle(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void send_info(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);
void handle_test(IRomiSerial *romiSerial, int16_t *args, const char *string_arg);

const static MessageHandler handlers[] = {
        { 'm', 4, false, handle_moveto },
        { 'M', 4, false, handle_move },
        { 'V', 3, false, handle_moveat },
        { 'p', 0, false, handle_pause },
        { 'c', 0, false, handle_continue },
        { 'r', 0, false, handle_reset },
        { 'P', 0, false, send_position },
        { 'I', 0, false, send_idle },
        { 'H', 0, false, handle_homing },
        { 'h', 3, false, handle_set_homing },
        { 'E', 1, false, handle_enable },
        { 'S', 1, false, handle_spindle },
        { 'T', 1, false, handle_test },
        { '?', 0, false, send_info },
};

ArduinoSerial serial(Serial);
RomiSerial romiSerial(serial, serial, handlers, sizeof(handlers) / sizeof(MessageHandler));

static char reply_string[80];
static int8_t homing_axes[3] =  {-1, -1, -1};
static int16_t homing_speeds[3] =  {1000, 1000, 400};
static uint8_t limit_switches[3] = {0, 0, 0};

int moveat(int dx, int dy, int dz);


void reset()
{
        block_buffer_clear();
        stepper_reset();
}

/**
 * \brief Check the accuracy of the path following.
 *
 * Check that the difference between the actual position of the arm,
 * as measured by the encoders, and the supposed position of the arm,
 * as measured by the number of executed motor steps, is less than a
 * given threshold. If the deviation is larger than the threshold then
 * the controller will stop the execution and request the controlling
 * program to make the necessary adjustments.
 */
void check_accuracy()
{
}

void setup()
{
        disable_driver();
        
        Serial.begin(115200);
        while (!Serial)
                ;
        
        init_block_buffer();
        init_pins();
        init_stepper();

        controller_state = STATE_RUNNING;
        enable_stepper_timer();
}

static unsigned long last_time = 0;
static unsigned long last_print_time = 0;
static int16_t id = 0;

void loop()
{
        romiSerial.handle_input();
        check_accuracy();
        delay(1);
}


int moveat(int dx, int dy, int dz)
{
        int err = 0;
        block_t *block = block_buffer_get_empty();
        if (block == 0) {
                err = -1;
        } else {                
                block->type = BLOCK_MOVEAT;
                block->data[DT] = 1000;
                block->data[DX] = dx;
                block->data[DY] = dy;
                block->data[DZ] = dz;
                block_buffer_ready();
        }
        return err;
}

int move(int dt, int dx, int dy, int dz)
{
        int err = 0;
        block_t *block = block_buffer_get_empty();
        if (block == 0) {
                err = -1;
        } else {
                block->type = BLOCK_MOVE;
                block->data[DT] = dt;
                block->data[DX] = dx;
                block->data[DY] = dy;
                block->data[DZ] = dz;
                block_buffer_ready();
        }
        return err;
}

void handle_moveto(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_RUNNING
            || controller_state == STATE_PAUSED) {
                if (args[0] > 0) {
                        block_t *block = block_buffer_get_empty();
                        if (block == 0) {
                                romiSerial->send_error(1, "Again");  
                        } else {
                                block->type = BLOCK_MOVETO;
                                block->data[DT] = args[0];
                                block->data[DX] = args[1];
                                block->data[DY] = args[2];
                                block->data[DZ] = args[3];
                                block_buffer_ready();
                                romiSerial->send_ok();  
                        }
                } else {
                        romiSerial->send_error(100, "Invalid DT");  
                }
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void handle_move(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_RUNNING
            || controller_state == STATE_PAUSED) {
                if (args[0] > 0) {
                        if (move(args[0], args[1], args[2], args[3]) == 0) {
                                romiSerial->send_ok();  
                        } else {
                                romiSerial->send_error(1, "Again");  
                        }
                } else {
                        romiSerial->send_error(100, "Invalid DT");                  
                }
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void handle_moveat(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_RUNNING
            || controller_state == STATE_PAUSED) {

                if (moveat(args[0], args[1], args[2]) == 0) {
                        romiSerial->send_ok();  
                } else {
                        romiSerial->send_error(1, "Again");  
                }
                
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void handle_pause(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_RUNNING) {
                disable_stepper_timer();
                controller_state = STATE_PAUSED;
                romiSerial->send_ok();  
        } else if (controller_state == STATE_PAUSED) {
                romiSerial->send_ok();  
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void handle_continue(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_PAUSED) {
                controller_state = STATE_RUNNING;
                enable_stepper_timer();
                romiSerial->send_ok();  
        } else if (controller_state == STATE_RUNNING) {
                romiSerial->send_ok();  
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void handle_reset(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (controller_state == STATE_PAUSED) {
                controller_state = STATE_RUNNING;
                reset();
                enable_stepper_timer();
                romiSerial->send_ok();  
        } else if (controller_state == STATE_RUNNING) {
                reset();
                romiSerial->send_ok();  
        } else {
                romiSerial->send_error(101, kInvalidState);  
        }
}

void send_position(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        int32_t pos[3];
        get_stepper_position(pos);

        snprintf(reply_string, sizeof(reply_string),
                 "[0,%ld,%ld,%ld]", pos[0], pos[1], pos[2]);
        
        romiSerial->send(reply_string); 
}

static inline bool is_idle()
{
        return ((controller_state == STATE_RUNNING)
                && stepper_is_idle());
}

static inline void wait()
{
        while (!is_idle()) {
                romiSerial.handle_input();
                delay(1);
        }
}

void send_idle(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        snprintf(reply_string, sizeof(reply_string), "[0,%d,\"%c\"]",
                 is_idle(), controller_state);
        romiSerial->send(reply_string); 
}

void update_limit_switches()
{
        limit_switches[0] = digitalRead(PIN_LIMIT_SWITCH_X);
        limit_switches[1] = digitalRead(PIN_LIMIT_SWITCH_Y);
        limit_switches[2] = digitalRead(PIN_LIMIT_SWITCH_Z);
}

int homing_move(int dt, int delta, int axis)
{
        int r;
        if (axis == 0)
                r = move(dt, delta, 0, 0);
        else if (axis == 1)
                r = move(dt, 0, delta, 0);
        else if (axis == 2)
                r = move(dt, 0, 0, delta);
        return r;
}

int homing_moveat(int v, int axis)
{
        int r;
        if (axis == 0)
                r = moveat(v, 0, 0);
        else if (axis == 1)
                r = moveat(0, v, 0);
        else if (axis == 2)
                r = moveat(0, 0, v);
        return r;
}

int homing_wait_switch(int speed, int axis, int state)
{
        int err = 0;
        int dx, dy, dz;

        // Serial.print("#!Axis=");
        // Serial.print(axis);
        // Serial.print(":xxxx\r\n");

        err = homing_moveat(speed, axis);
        if (err != 0)
                return err;
        
        while (1) {
                update_limit_switches();
                // Serial.print("#!L=");
                // Serial.print(limit_switches[axis]);
                // Serial.print(":xxxx\r\n");
                
                if (limit_switches[axis] == state) {
                        err = move(0, 0, 0, 0); // This will stop the moveat
                        break;
                }
                
                romiSerial.handle_input();
                delay(1);
        }
        return err;
}

int homing_moveto_switch_pressed(int axis)
{
        return homing_wait_switch(-homing_speeds[axis], axis, LOW);
}

int homing_moveto_switch_released(int axis)
{
        return homing_wait_switch(homing_speeds[axis], axis, HIGH);
}

bool do_homing_axis(int axis)
{
        bool success = false; 
        if (homing_moveto_switch_pressed(axis) == 0 
            && homing_moveto_switch_released(axis) == 0
            && homing_move(100, homing_speeds[axis]/5, axis) == 0) {
                // Don't remove the RUNNING because wait() depends on
                // it!
                controller_state = STATE_RUNNING;
                wait();
                success = true;
        }
        return success;
}

bool do_homing()
{
        bool success = true;
        for (int i = 0; i < 3; i++) {
                if (homing_axes[i] >= 0 && homing_axes[i] < 3) {
                        success = do_homing_axis(homing_axes[i]);
                        if (!success)
                                break;
                }
        }
        return success;
}

void handle_homing(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        // Stop whatever is ongoing
        reset();

        // Make sure the timer is running
        enable_stepper_timer();

        controller_state = STATE_HOMING;

        // Reply the client immediately because there's a timeout on
        // sending a response.
        romiSerial->send_ok();
        
        if (do_homing()) {
                reset();
                stepper_zero();
                controller_state = STATE_RUNNING;
        } else {
                controller_state = STATE_ERROR;
        }
}

void handle_set_homing(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        for (int i = 0; i < 3; i++)
                homing_axes[i] = args[i];        
        romiSerial->send_ok();
}

void handle_enable(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (args[0] == 0) {
                disable_driver();
        } else {
                enable_driver()
        }
        romiSerial->send_ok();
}

void handle_spindle(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        if (args[0] == 0) {
                digitalWrite(PIN_SPINLDE, LOW);
        } else {
                digitalWrite(PIN_SPINLDE, HIGH);
        }
        romiSerial->send_ok();
}

void send_info(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        romiSerial->send("[0,\"Oquam\",\"0.1\",\"" __DATE__ " " __TIME__ "\"]"); 
}

static bool quit_testing;

void start_test()
{
        quit_testing = false;
        while (!quit_testing) {
                
                moveat(1000, 1000, 100);
                delay(500);
                
                moveat(-1000, -1000, -100);
                delay(500);
                
                update_limit_switches();
                Serial.print("#![");
                Serial.print(limit_switches[0]);
                Serial.print(',');
                Serial.print(limit_switches[1]);
                Serial.print(',');
                Serial.print(limit_switches[2]);
                Serial.print("]:xxxx\r\n");

                romiSerial.handle_input();
        }
}

void stop_test()
{
        quit_testing = true;
        moveat(0, 0, 0);
}

void handle_test(IRomiSerial *romiSerial, int16_t *args, const char *string_arg)
{
        romiSerial->send_ok();
        if (args[0] == 0) {
                stop_test();
        } else {
                start_test();
        }
}
