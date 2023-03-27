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
#include <avr/io.h>
#include <avr/interrupt.h>
#include "gshield.h"

#ifndef _OQUAM_STEPPER_H_
#define _OQUAM_STEPPER_H_

/**
 *  \brief The possible states of the stepper thread.
 */
enum {
        STATE_THREAD_IDLE,
        STATE_THREAD_EXECUTING
};

/**
 * \brief: Configure the stepper. Must be called with interrupts
 * disabled (see cli()).
 *
 */
void init_stepper();


/**
 * \brief: Sets the current position as the orginin.
 *
 */
void stepper_zero();

void stepper_reset();

bool stepper_is_idle();

void get_stepper_position(int32_t *pos);


/**
 * \brief: Configure Timer1 to drive the stepper's STEP pulse train.
 *
 *  Timer1 is used as the "stepper timer", i.e. this timer will pulse
 *  the STEP pins of the stepper drivers.
 */
void init_stepper_timer();

/**
 * \brief: Initialize Timer2 to reset the STEP pins back to zero 10 µs
 * after a pulse.
 *
 *  Timer2 is used as the "reset step timer", i.e. this timer will
 *  pulse the set the STEP pins of the stepper drivers to zero 10 µs
 *  after they have been raised to 1 by the stepper timer.
 */
void init_reset_step_pins_timer();

/**
 * \brief Disable/enable the stepper driver.
 */
#if ENABLE_PIN_HIGH
#define enable_driver()  set_enable_pin_high()
#define disable_driver() set_enable_pin_low()
#else
#define enable_driver()  set_enable_pin_low()
#define disable_driver() set_enable_pin_high()
#endif

//extern volatile uint8_t thread_state;

#define enable_reset_step_pins_timer()                                  \
        {                                                               \
                /* Initialize counter */                                \
                TCNT2 = 0;                                              \
                /* Enable Timer2 */                                     \
                TIMSK2 |= (1 << OCIE2A);                                \
        }

#define disable_reset_step_pins_timer()                                 \
        {                                                               \
                /* Disable Timer2 interrupt */                          \
                TIMSK2 &= ~(1 << OCIE2A);                               \
        }

#define enable_stepper_timer()                                          \
        {                                                               \
                /* Initialize counter */                                \
                TCNT1 = 0;                                              \
                /* Set the status of the stepper thread */              \
                /* thread_state = STATE_THREAD_EXECUTING; */            \
                /* Enable Timer1 */                                     \
                TIMSK1 |= (1 << OCIE1A);                                \
        }

#define disable_stepper_timer()                                         \
        {                                                               \
                /* Set the status of the stepper thread */              \
                /*thread_state = STATE_THREAD_IDLE;*/                   \
                /* Disable Timer1 interrupt */                          \
                TIMSK1 &= ~(1 << OCIE1A);                               \
        }

#endif // _OQUAM_STEPPER_H_
