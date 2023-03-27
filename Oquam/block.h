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
/**
 * The files block.c and block.cpp define the block_t data
 * structure and a set of function to manipulate the block
 * buffer. The block buffer is a circular buffer. It only handle one
 * writer (the main thread) and one reader (the interrupt-driver
 * stepper thread).
 *
 */
#include <stdint.h>

#ifndef _OQUAM_BLOCK_H_
#define _OQUAM_BLOCK_H_

/**
 * \brief The possible block types.
 */
enum {
        BLOCK_MOVE = 0,
        BLOCK_MOVETO,
        BLOCK_MOVEAT,
};

/**
 * \brief The data fields for the move block.
 */
enum {
        DT = 0,
        DX = 1,
        DY = 2,
        DZ = 3
};

/**
 * \brief The 'block' structure contains the information of one
 * instruction.
 *
 * The controller can execute the following types of blocks:
 *
 * 1. MOVE: This block represents a physical movement. The block
 *    contains the following data fields: a) the duration of the
 *    movement in milliseconds (data[0]), b) the number of motor steps
 *    to execute in each of the three directions (data[1-3]). The
 *    displacement is relative to the current position.
 *
 * 2. MOVETO: Similar to 'move'. However in this case, the position
 *    indicates an absolute position.
 *
 * 3. MOVEAT: This request to move at at given speed. The speed values
 *    are incoded in the DX, DY and DZ field and are measured in
 *    steps/second.
 */
struct block_t {
        uint8_t type;
        int16_t data[4];
};

/* The buffer size should be a power of two. */
#define BLOCK_BUFFER_SIZE 32
#define BLOCK_BUFFER_SIZE_MASK (BLOCK_BUFFER_SIZE - 1)

/**
 * \brief The 'block_buffer' is a circular buffer of blocks.
 */
struct block_buffer_t {
        int16_t readpos;
        int16_t writepos;
        block_t block[BLOCK_BUFFER_SIZE];
};

extern block_buffer_t block_buffer;

/**
 * \brief Initializes the block buffer.
 */
void init_block_buffer();

/**
 * \brief Returns the number of empty block slots in the buffer.
 */
int16_t block_buffer_space();

/**
 * \brief Returns a pointer to the next of empty block slot but
 * doesn't mark the slot as ready.
 *
 * Returns NULL if there are no empty block slots in the buffer.
 */
block_t *block_buffer_get_empty();

/**
 * \brief Marks the next empty slot as ready.
 *
 * This function should be called after having obtained an block slot
 * using block_buffer_get_empty() and when the block is initialized.
 */
void block_buffer_ready();

/*
 * The macro should not be used directly. Either use
 * block_buffer_available() or block_buffer_get_next().
 *
 * The generic implementation to compute the available space is:
 *
 * if (block_buffer.writepos >= block_buffer.readpos)
 *         return block_buffer.writepos - block_buffer.readpos;
 * else 
 *         return (BLOCK_BUFFER_SIZE
 *                 + block_buffer.writepos
 *                 - block_buffer.readpos);
 *
 * The code below takes advantage from the fact that the buffer size
 * is a power of two.
 */
#define BLOCK_BUFFER_AVAILABLE()                                \
        ((BLOCK_BUFFER_SIZE + block_buffer.writepos             \
          - block_buffer.readpos) & BLOCK_BUFFER_SIZE_MASK)

/**
 * \brief Returns the number of blocks waiting to be executed.
 */
int16_t block_buffer_available();


/*
 * This is a private function. Use block_buffer_get_next() instead.
 */
block_t *_block_buffer_get_next();

/**
 * \brief Returns a pointer to the next of block to be executed.
 *
 * Returns 0 if there are no more blocks to be executed in the
 * buffer.
 */
#define block_buffer_get_next() \
        ((BLOCK_BUFFER_AVAILABLE() == 0)? 0 : _block_buffer_get_next())


/**
 * \brief Removes all the blocks and empties the circular buffer.
 */
void block_buffer_clear();



// DEBUG
int16_t block_buffer_readpos();
int16_t block_buffer_writepos();

#endif // _OQUAM_BLOCK_H_
