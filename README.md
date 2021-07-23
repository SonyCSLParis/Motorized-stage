# Motorised-stage

Github moteur

intro

Objectif 2 phrases

The goal of this project is to enable the motorised and automated movement of a stage in order to study individually a set of unicellular algae trapped in a microfluidic chip. Such a study requires precise control of the movement on a micrometric scale. For each direction we used a stepper motor controlled via an Arduino UNO microcontroller and an EasyDriver microcontroller. We also had to design 3D parts to link the motors to the stage. 

[image avant - après]


# Bill of materials

## Hardware :gear:

| Component|      Quantity      |  Price per unit | Where to find |  
|----------|:-------------:|------:|------:|  
| Manual XY stage |  1 | $289 | [Amazon](https://www.manualpositioning.com/e_products_show/?id=45)|  
| Arduino Uno |    1   |   24€ | [Robotshop](https://www.robotshop.com/eu/fr/microcontroleur-arduino-uno-r3-usb.html)|  
| Stepper driver | 2 |    10€ | [Robotshop](https://www.robotshop.com/eu/fr/controleur-moteur-pas-easydriver.html?gclid=EAIaIQobChMIhLiChaj58QIVxQwGAB1bUgYvEAQYASABEgIi8vD_BwE) |  
| Stepper motor |1 | |  
| Stepper motor with gearbox | 1| |  
| Connection wires | | |  
| Screws M2, M3 | | |  
| Motor belt GT2 | | |
| Motor pulley | | | |

## Software :desktop_computer:
All open-source software

| Software | Version we used | Download |
|----------|:-------------:|:-------------:|  
| Freecad | 0.19 |  [download](https://wiki.freecadweb.org/Download)
| Arduino | 1.8.13 | [download](https://www.arduino.cc/en/software)
| Python  | 3.7 |[install](https://github.com/Alienor134/Teaching/blob/master/Python/Installing_Anaconda_creating_environment.md)



## Codes and files provided :chart_with_upwards_trend:

### 3D designs: 
- [small button pulley]  (modified from [manueaswn's scalable pulley](https://www.thingiverse.com/thing:387598 ) )
- [large button pulley]
- [plate element]

### Control of motors by Arduino 
- [romi repo] (written for the [Romi Project](https://github.com/romi/libromi))
- [python interface]


Results

In the end we were able to control the movement of the stage to go from one trap to the following one. The following animation shows a trap and its neighbour appearing one after the other in the center of the camera.

[gif]

By using the EasyDriver we could rotate each motor by on microstep. In the end the set-up enabled us to reach a minimal movement of $1,95$ $\mu$m along the $x$ axis and of $0,05$ $\mu$m along the $y$ axis.

In order to estimate the quality of our set-up, we measured its precision using the registration method which calculates the spatial correlation between two successive images.

On the one hand the analyses of these results shows that the stage moves linearly along the $y$ axis as expected. We concluded that our set-up was of good quality for this direction.

[graphe]

On the other hand we discovered that the movement along the $x$ axis is flawed. Indeed when moving the stage along this axis we regularly measure a small unwanted movement along the $y$ axis. This shortcoming leads to imprecise movement along the $x$ axis.

[graphe]

Set-up

3D Printing

To link the stepper motors to the stage we had to print two slave pulleys - one for each knob. We did that using the free and open source design and modeling software FreeCAD. We first wanted to design these slave pulleys so that moving the stepper motors by one microstep would move the stage by $5$ $\mu$m.

For the $y$-axis knob we were using the 42STH38 stepper motor which has 1600 microsteps per revolution. We determined that one turn of the $y$-axis knob moves the stage by 4 cm. Knowing that the master pulley has 20 teeth we calculated that the $y$-axis slave pulley needed to have 100 teeth.

[image]

For the $x$-axis we measured that one turn of the knob moves the stage by 2,5 cm. In the case of the $x$ axis the 17HM08-1204S stepper motor has 3200 microsteps per revolution and the master pulley has 20 teeth. Thus we calculated that the $x$-axis slave pulley needed to have 32 teeth. Such a little number of teeth leads to modeling issues.

Thus we decided to design an 80 teeth slave pulley for the $x$-axis knob. This leads to a higher precision : when the stpper motor rotates by 1 microstep, the stage moves by $1,95$ $\mu$m along the $x$ axis.

[image]

comment procéder

Impression des pièces 3D :
fournir nos pièces freecad ou expliquer comment on les a fabriquées (calcul de précision)
1. Montage 
lien vers le driver, schéma moteurs
3. code arduino
lien repo Peter expliquer comment l'installer (mettre la lib de romi dans le dossier arduino)
4. interface python

contribute 

licence

