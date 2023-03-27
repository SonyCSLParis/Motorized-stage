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

block_buffer_t block_buffer;

int16_t block_buffer_readpos()
{
        return block_buffer.readpos;
}

int16_t block_buffer_writepos()
{
        return block_buffer.writepos;
}

void init_block_buffer()
{
        block_buffer.readpos = 0;
        block_buffer.writepos = 0;
}

static inline int16_t _space()
{
        if (block_buffer.writepos >= block_buffer.readpos)
                return (BLOCK_BUFFER_SIZE
                        - block_buffer.writepos
                        + block_buffer.readpos - 1);
        else
                return block_buffer.readpos - block_buffer.writepos - 1;

        // The following optimization takes advantage from the fact
        // that the buffer size is a power of two.
        // return (BLOCK_BUFFER_SIZE
        //         - block_buffer.writepos
        //         + block_buffer.readpos - 1) & BLOCK_BUFFER_SIZE_MASK;
}

int16_t block_buffer_space()
{
        return _space();
}

block_t *block_buffer_get_empty()
{
        if (_space() == 0)
                return 0;
        return &block_buffer.block[block_buffer.writepos];
}

void block_buffer_ready()
{
        int16_t p = block_buffer.writepos + 1;
        if (p == BLOCK_BUFFER_SIZE)
                p = 0;
        block_buffer.writepos = p;
}

int16_t block_buffer_available()
{
        return BLOCK_BUFFER_AVAILABLE();
}

block_t *_block_buffer_get_next()
{
        block_t *b = &block_buffer.block[block_buffer.readpos];
        block_buffer.readpos++;
        block_buffer.readpos &= BLOCK_BUFFER_SIZE_MASK;
        return b;
}

void block_buffer_clear()
{
        block_buffer.readpos = block_buffer.writepos;
}
