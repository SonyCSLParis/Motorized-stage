
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
from python_comm import *
import numpy as np
import tkinter as tk

root = tk.Tk()
root.title('Command interface')
frame = tk.Frame(root)
frame.pack()

x = 0
y = 0

port_arduino = 'COM6' #adapt the port to your arduino port !
link = Serial(port_arduino, 115200)

"""--------Useful functions-------------"""

#x displacement
def move_dx (link, dx, dt=-1) :
    if dt == -1:
        dt = dx*10 #adjust displacement speed according to the displacement length dx
    handle_move(link, np.abs(dt), dx, 0, 0) # send commmand to the Arduino
    global x
    global var_x
    x += dx
    var_x.set("x = "+str(x)) #allows to display the global x displacement

# y displacement
def move_dy (link, dy, dt = -1) :
    if dt == -1:
        dt = dy//10 #adjust displacement speed according to the displacement length dy (considering the gearbox with ration x100)
    handle_move(link, np.abs(dt), 0, dy, 0) # send commmand to the Arduino
    global y
    global var_y
    y += dy//100
    var_y.set("y = "+ str(y)) #allows to display the global y displacement

def move_x_entry(): #move using user input value
    dx = np.int(entry_x.get())
    move_dx(link, dx, dt=-1)


def move_y_entry(): #move using user input value
    dy = np.int(entry_y.get())
    move_dy(link, dy*100, dt=-1)


def handle_enable(link, enable): #enable or diable to allow automatic or manual commmand respectively
    send_command(link, "E[%d]"%int(enable))
        
def toggle(): #Enable or disable motor control
    if enable_button.config('text')[-1] == 'Enable':
        handle_enable(link, 1)
        enable_button.config(text='Disable')
    else:
        handle_enable(link, 0)
        enable_button.config(text='Enable')


"""--------Buttons-----------"""
#leave the app
quit_button = tk.Button(frame, 
                   text="QUIT", 
                   fg="red",
                   command=quit)

quit_button.grid(column=0, row=2, ipadx=5, pady=5)

#enable or disable motors
enable_button = tk.Button(frame, text="ENABLE", fg="black", command=toggle)
enable_button.grid(column= 1, row=2, ipadx=5, pady=5)


#get global displacement values x and y
var_x = tk.StringVar()
label_x = tk.Label(frame, textvariable = var_x) #shows as text in the window
label_x.grid(column=0, row=0, columnspan=5, ipadx=5, pady=5)

var_y = tk.StringVar()
label_y = tk.Label(frame, textvariable = var_y) #shows as text in the window
label_y.grid(column=0, row=1, columnspan=5, ipadx=5, pady=5)

# user inputs valus and clicks to move
entry_x = tk.Entry(frame)
entry_x.grid(column = 4, row=0, ipadx=5, pady=5 )    
user_x = tk.Button(frame, text = 'move x', command = move_x_entry)
user_x.grid(column = 5, row=0, ipadx=5, pady=5 )

entry_y = tk.Entry(frame)
entry_y.grid(column = 4, row=1, ipadx=5, pady=5 )    
user_y = tk.Button(frame, text = 'move y', command = move_y_entry)
user_y.grid(column = 5, row=1, ipadx=5, pady=5 )

# predefined movements x and y (+/- 100, 50 or 10)
button2 = tk.Button(frame,
                   text="x - 100", fg="blue", bg="yellow",
                   command = lambda :move_dx(link, -100, -1))

button2.grid(column=0, row=3, ipadx=5, pady=5)

button3 = tk.Button(frame,
                   text="x - 50", fg="blue", bg="yellow",
                   command = lambda :move_dx(link, -50, -1))

button3.grid(column=0, row=4, ipadx=5, pady=5)

button4 = tk.Button(frame,
                   text="x - 10", fg="blue", bg="yellow",
                   command = lambda : move_dx(link, -10, -1))

button4.grid(column=0, row=5, ipadx=5, pady=5)

button5 = tk.Button(frame,
                   text="x + 10", fg="blue", bg="yellow",
                   command = lambda : move_dx(link, 10, -1))

button5.grid(column=1, row=3, ipadx=5, pady=5)

button6 = tk.Button(frame,
                   text="x + 50", fg="blue", bg="yellow",
                   command = lambda : move_dx(link, 50, -1))

button6.grid(column=1, row=4, ipadx=5, pady=5)

button7 = tk.Button(frame,
                   text="x + 100", fg="blue", bg="yellow",
                   command = lambda : move_dx(link, 100, -1))

button7.grid(column=1, row=5, ipadx=5, pady=5)

button8 = tk.Button(frame,
                   text="y - 100", fg="white", bg="red",
                   command = lambda : move_dy(link, -100*100, -1))

button8.grid(column=3, row=3, ipadx=5, pady=5)

button9 = tk.Button(frame,
                   text="y - 50", fg="white", bg="red",
                   command = lambda : move_dy(link, -50*100, -1))

button9.grid(column=3, row=4, ipadx=5, pady=5)

button10 = tk.Button(frame,
                   text="y - 10", fg="white", bg="red",
                   command = lambda : move_dy(link, -10*100, -1))

button10.grid(column=3, row=5, ipadx=5, pady=5)

button11 = tk.Button(frame,
                   text="y + 10", fg="white", bg="red",
                   command = lambda : move_dy(link, 10*100, -1))

button11.grid(column=4, row=3, ipadx=5, pady=5)

button12 = tk.Button(frame,
                   text="y + 50", fg="white", bg="red",
                   command = lambda : move_dy(link, 50*100, -1))
button12.grid(column=4, row=4, ipadx=5, pady=5)

button13 = tk.Button(frame,
                   text="y + 100", fg="white", bg="red",
                   command = lambda : move_dy(link, 100*100, -1))

button13.grid(column=4, row=5, ipadx=5, pady=5)



root.mainloop()