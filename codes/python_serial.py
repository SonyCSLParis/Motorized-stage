"""
  Motorised Stage

  Copyright (C) 2021 Sony Computer Science Laboratories
  Author(s) Ali Ruyer-Thompson, Aliénor Lahlou, Peter Hanappe

  Motorised Stage allows to control the position of a microscope stage.

  Motorised Stage is free software: you can redistribute it and/or modify
  it under the terms of the GNU Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see
  <http://www.gnu.org/licenses/>.

"""
from serial import *
import time
import json
import traceback

#Source ROMI Github: https://github.com/romi/romi-rover-build-and-test
def send_command(link, s):
    print("Command: %s" % s)
    command = "#" + s + ":xxxx\r\n"
    print(command)
    link.write(command.encode('ascii'))
    return assert_reply(read_reply(link))


def read_reply(link):
    while True:
        s = link.readline().decode("ascii").rstrip()

        if s[0] == "#":
            if s[1] == "!":
                print("Log: %s" % s)
            else:
                print("Reply: %s" % s)
                break;
    return s


def assert_reply(line):
    s = str(line)
    start = s.find("[")
    end = 1 + s.find("]")
    array_str = s[start:end]
    return_values = json.loads(array_str)
    print(return_values)
    status_code = return_values[0]
    success = (status_code == 0)
    if not success:
        raise RuntimeError(return_values[1])
    return return_values


def handle_moveto(link, t, x, y, z):
    """move the motor to absolute position"""
    send_command(link, "m[%d,%d,%d,%d]" % (t, x, y, z))


def handle_move(link, dt, dx, dy, dz):
    """move the motor by relative displacement"""
    send_command(link, "M[%d,%d,%d,%d]" % (dt, dx, dy, dz))


def handle_pause(link):
    """pause after the ongoing moving task"""
    send_command(link, "p")


def handle_continue(link):
    """restart after pause"""
    send_command(link, "c")


def send_idle(link):
    """assert the connection is correctly established"""
    reply = send_command(link, "I")
    return reply[1]


def handle_set_homing(link, a, b, c):
    """configure the homing order. x:0, y:1, z:2, skip:-1. 
    Example: set y, then x: handle_set_homing(link, 1, 0, -1)"""
    send_command(link, "h[%d,%d,%d]" % (a,b,c))


def handle_homing(link):
    """perform homing in the order set by "handle_set_homing"""
    send_command(link, "H")

    
def handle_enable(link, enable):
    # Enable or diable to allow automatic or manual commmand
    # respectively
    send_command(link, "E[%d]"%int(enable))


#source: https://forum.arduino.cc/t/arduino-and-python/39999
def reset_arduino(link):
    link.setDTR(False) 
    time.sleep(0.022)    
    link.setDTR(True)  
    time.sleep(2)

"""
port_arduino = 'COM6'
link_arduino = Serial(port_arduino, 115200)

time.sleep(2.0)

reset_arduino(link_arduino)

#handle_moveto(link_arduino, 2000, 1600, 0, 0)

handle_move(link_arduino,  6000, 1600, 0, 0) 

handle_pause(link_arduino) #ici mettre la fonction pause

time.sleep(2.0)

handle_continue(link_arduino) 

handle_move(link_arduino,  6000, -1600, 0, 0)
#check si on est 
status = send_idle(link_arduino)
print(status)

link_arduino.close() 
"""
