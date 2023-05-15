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

#ifndef _OQUAM_GSHIELD_H_
#define _OQUAM_GSHIELD_H_

#define ENABLE_PIN_HIGH   0
#define ENCODER_REVERSED 0
/* #define PRESCALING         1 */
/* #define FREQUENCY_STEPPER  25000 */
/* #define INTERRUPTS_PER_MILLISECOND 25 */
#define PRESCALING         8
#define FREQUENCY_STEPPER  10000
#define INTERRUPTS_PER_MILLISECOND 10

#define PIN_LIMIT_SWITCH_X   9
#define PIN_LIMIT_SWITCH_Y   10
#define PIN_LIMIT_SWITCH_Z   11
#define PIN_SPINLDE          12

/* 
 * The STEP_ and DIRECTION_ defines below are taken from Grbl.
 */

/** 
 * Define step pulse output pins. NOTE: All step bit pins must be on
 * the same port. 
 */
#define STEP_DDR          DDRD
#define STEP_PORT         PORTD
#define X_STEP_BIT        2  // Uno Digital Pin 2
#define Y_STEP_BIT        3  // Uno Digital Pin 3
#define Z_STEP_BIT        4  // Uno Digital Pin 4
#define STEP_MASK         ((1 << X_STEP_BIT) | (1 << Y_STEP_BIT) | (1 << Z_STEP_BIT))

/** 
 * Define step direction output pins. NOTE: All direction pins must be
 * on the same port.
 */
#define DIRECTION_DDR     DDRD
#define DIRECTION_PORT    PORTD
#define X_DIRECTION_BIT   5  // Uno Digital Pin 5
#define Y_DIRECTION_BIT   6  // Uno Digital Pin 6
#define Z_DIRECTION_BIT   7  // Uno Digital Pin 7
#define DIRECTION_MASK    ((1<<X_DIRECTION_BIT)|(1<<Y_DIRECTION_BIT)|(1<<Z_DIRECTION_BIT))

/**
 * Define stepper driver enable/disable output pin.
 */
#define STEPPERS_DISABLE_DDR    DDRB
#define STEPPERS_DISABLE_PORT   PORTB
#define STEPPERS_DISABLE_BIT    0  // Uno Digital Pin 8
#define STEPPERS_DISABLE_MASK   (1 << STEPPERS_DISABLE_BIT)

/**
 * \brief Configure the step and dir pins as output.
 */
void init_pins();

/**
 * \brief Raise the enable pin.
 */
#define set_enable_pin_high()                                               \
        {                                                               \
                STEPPERS_DISABLE_PORT |= (1 << STEPPERS_DISABLE_BIT);   \
        }

/**
 * \brief Reset the enable pin.
 */
#define set_enable_pin_low()                                            \
        {                                                               \
                STEPPERS_DISABLE_PORT &= ~(1 << STEPPERS_DISABLE_BIT);  \
        }


/**
 * \brief Enable the step pins according to mask.
 */
#define set_step_pins(__mask)                           \
        {                                               \
                STEP_PORT |= __mask;                    \
        }

/**
 * \brief Reset the step pins to zero.
 */
#define reset_step_pins()                               \
        {                                               \
                STEP_PORT &= ~STEP_MASK;                \
        }

/**
 * \brief Toggle a step bit in the pins mask.
 */
#define toggle_step(__mask, __axis)                     \
        {                                               \
                __mask |= (1 << __axis);                \
        }

#define toggle_x_step(__mask)  toggle_step(__mask, X_STEP_BIT)
#define toggle_y_step(__mask)  toggle_step(__mask, Y_STEP_BIT)
#define toggle_z_step(__mask)  toggle_step(__mask, Z_STEP_BIT)

/**
 * \brief Enable the DIR pins according to mask.
 */
#define set_dir_pins(__pins)                            \
        {                                               \
                DIRECTION_PORT &= ~DIRECTION_MASK;      \
                DIRECTION_PORT |= __pins;               \
        }

/**
 * \brief Toggle a direction bit in the DIR mask.
 */
#define toggle_dir(__mask, __axis)                      \
        {                                               \
                __mask |= (1 << __axis);                \
        }

#define toggle_x_dir(__mask)  toggle_dir(__mask, X_DIRECTION_BIT)
#define toggle_y_dir(__mask)  toggle_dir(__mask, Y_DIRECTION_BIT)
#define toggle_z_dir(__mask)  toggle_dir(__mask, Z_DIRECTION_BIT)

#endif // _OQUAM_GSHIELD_H_
