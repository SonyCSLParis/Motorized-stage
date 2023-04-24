include <materials.scad>
include <units.scad>

// Expected kLength: 85 + 6 + 6 + 30 = 127 mm
// Measured kLength: 127.25 mm
kLength = 127*mm;
kWidth = 30*mm;
kHeight = 35*mm;

kMotorLength = 30*mm;
kMotorWidth = 28*mm;
kMotorHeight = 28*mm;

kMotorPlateDepth = 6*mm;
kMotorPlateWidth = kWidth;
kMotorPlateHeight = kHeight;

kFrontPlateDepth = 6*mm;
kFrontPlateWidth = kWidth;
kFrontPlateHeight = 28*mm;
kFrontPlateScrewHeadDiameter = 5.8*mm;
kFrontPlateScrewHeadOffset = 0.1*mm;
kFrontPlateScrewDistance = 20*mm;

kDistancePlates = kLength - kMotorLength - kFrontPlateDepth - kMotorPlateDepth;
kAxisLength = kDistancePlates + kFrontPlateDepth + kMotorPlateDepth;
kAxisDiameter = 6*mm;

kOffsetMotorAndMotorPlate = 0.3*mm;
kOffsetBottom = -kMotorPlateHeight + kMotorHeight/2 + kOffsetMotorAndMotorPlate;

kBottomLength = kDistancePlates;
kBottomWidth = kWidth;
kBottomHeight = 13.42*mm;

kSliderLength = 32*mm;
kSliderWidth = kWidth;
kSliderHeight = 14*mm;
kSliderDistanceHoles = 20*mm;
kSliderHoleDiameter = 5*mm;
kSliderOffsetAxis = 8*mm;

module Motor()
{
    color(BlackPaint)
    translate([-kMotorLength, -kMotorWidth/2, -kMotorHeight/2]) {
        cube([kMotorLength, kMotorWidth, kMotorHeight]);
    }
}

module MotorPlate()
{
    color(BlackPaint) {
        translate([-kMotorPlateDepth, 
                   -kMotorPlateWidth/2, 
                   kOffsetBottom]) {
                cube([kMotorPlateDepth, kMotorPlateWidth, kMotorPlateHeight]);
        }
    }
}

module FrontPlate()
{        
    color(BlackPaint) {
        translate([kDistancePlates, 0, 0])
        difference() {
            translate([0, -kFrontPlateWidth/2, kOffsetBottom]) {
                    cube([kFrontPlateDepth, kFrontPlateWidth, kFrontPlateHeight]);
            }
            translate([kFrontPlateDepth + epsilon, 0, 0]) {
                rotate([0, -90, 0]) {
                    cylinder(d = kAxisDiameter + epsilon,
                             h = kFrontPlateDepth + 2 * epsilon, $fn=360);
                }
            }
        }
    }
}

module Axis()
{
        color(Stainless) {
            translate([-kMotorPlateDepth, 0, 0])
            rotate([0, 90, 0])
                cylinder(d = kAxisDiameter, h = kAxisLength, $fn=360);
        }
}

module Bottom()
{
    color(BlackPaint) {
        translate([0, -kBottomWidth/2, kOffsetBottom]) {
            cube([kBottomLength, kBottomWidth, kBottomHeight]);
        }
    }
}

module Slider()
{
    color(BlackPaint) {
        translate([kSliderLength/2, 0, -(kSliderHeight - kSliderOffsetAxis)]) 
        difference() {
            translate([-kSliderLength/2, -kSliderWidth/2, 0]) {
                cube([kSliderLength, kSliderWidth, kSliderHeight]);
            }
            translate([kSliderDistanceHoles/2, kSliderDistanceHoles/2, -epsilon]) {
                cylinder(d = kSliderHoleDiameter, 
                         h = kSliderHeight + 2 * epsilon, $fn=360);
            }
            translate([kSliderDistanceHoles/2, -kSliderDistanceHoles/2, -epsilon]) {
                cylinder(d = kSliderHoleDiameter, 
                         h = kSliderHeight + 2 * epsilon, $fn=360);
            }
            translate([-kSliderDistanceHoles/2, kSliderDistanceHoles/2, -epsilon]) {
                cylinder(d = kSliderHoleDiameter, 
                         h = kSliderHeight + 2 * epsilon, $fn=360);
            }
            translate([-kSliderDistanceHoles/2, -kSliderDistanceHoles/2, -epsilon]) {
                cylinder(d = kSliderHoleDiameter, 
                         h = kSliderHeight + 2 * epsilon, $fn=360);
            }
        }
    }
}

module LinearSlider(pos)
{
    translate([-kMotorPlateDepth, 0, 0])
        Motor();
    
    translate([0, 0, 0])
        MotorPlate();

    translate([0, 0, 0])
        FrontPlate();
 
    translate([0, 0, 0])
        Axis();

    translate([0, 0, 0])
        Bottom();

    pos_min = 0;
    pos_max = kDistancePlates - kSliderLength;
    x = max(pos_min, min(pos_max, pos));

    translate([x*mm, 0, 0])
        Slider();
}

//LinearSlider(0);

