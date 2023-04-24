include <units.scad>

kUC2CubeSize = 49.8*mm;
kUC2ProfileThickness = 7.70*mm;
kUC2HeightBottom = kUC2CubeSize - kUC2ProfileThickness;

kUC2M3ScrewOffset = 4.9*mm;
kUC2M3HeadDiameter = 5.5*mm;
kUC2M3ShaftDiameter = 2.9*mm;
kUC2M3HeadHeight = 3.1*mm;
kUC2M3ShaftHeight = 15*mm;

kUC2M5OffsetX = 10.4*mm;
kUC2M5OffsetY = 4.1*mm;
kUC2M5Diameter = 4.7*mm;

kUC2Chamfer = 3.1*mm;//(kUC2ProfileThickness-3.77)*mm; // FIXME
kUC2WidthChamferCube = kUC2ProfileThickness * sqrt(2.0) + 0.2;

module UC2Profile(length, orientation, hole_diam, hole_length)
{
    translate([0, kUC2ProfileThickness/2, kUC2ProfileThickness/2]) {
        rotate([orientation, 0, 0]) {
            difference() {
                intersection() {
                    translate([0, -kUC2ProfileThickness/2, -kUC2ProfileThickness/2]) {
                            cube([length, kUC2ProfileThickness, kUC2ProfileThickness]);
                    }
                    rotate([45, 0, 0]) {
                            translate([0,
                                       -kUC2WidthChamferCube/2 - kUC2Chamfer,
                                       -kUC2WidthChamferCube/2]) {
                                    cube([length,
                                          kUC2WidthChamferCube,
                                          kUC2WidthChamferCube]);
                            }
                    }
                }
                translate([-0.01,
                           kUC2M3ScrewOffset - kUC2ProfileThickness/2,
                           kUC2M3ScrewOffset - kUC2ProfileThickness/2]) {
                    rotate([0, 90, 0]) {
                            cylinder(r=hole_diam/2,
                                     h=hole_length+0.01,
                                     $fn=360);
                    }
                }                            
            }
        }
    }
}

module UC2ProfileX(length, orientation)
{
    UC2Profile(length, orientation, 0, 0);
}

module UC2ProfileY(length, orientation)
{
    translate([0, length, 0]) {
        rotate([0, 0, -90]) {
            UC2Profile(length, orientation, 0, 0);
        }
    }
}

module UC2ProfileZ(length, orientation, hole_diameter, hole_length)
{
    translate([0, 0, length]) {
        rotate([0, 90, 0]) {
            UC2Profile(length, orientation, hole_diameter, hole_length);
        }
    }
}

module UC2VerticalBar(orientation)
{
    UC2ProfileZ(kUC2HeightBottom, orientation, kUC2M3ShaftDiameter, kUC2M3ShaftHeight);
}

module UC2M3Volume()
{
    union() {
        cylinder(r=kUC2M3HeadDiameter/2, h=kUC2M3HeadHeight+0.001, $fn=360);
        cylinder(r=kUC2M3ShaftDiameter/2, h=kUC2M3ShaftHeight, $fn=360);
    }
}

module UC2M5Volume()
{
    translate([0, 0, -2*kUC2ProfileThickness]) {
        cylinder(r=kUC2M5Diameter/2, h=4*kUC2ProfileThickness+0.002, $fn=360);
    }
}

kM3DiameterScrew = 3.0*mm;
kM3DiameterHead = 5.5*mm;
kM3HeightHead = 3*mm;

module UC2CubeBottomWithoutHoles()
{
    union() {
        // Two long bars going back to front
        translate([0, 0, 0]) {
                UC2ProfileX(kUC2CubeSize, 0);
        }
        translate([0, kUC2CubeSize - kUC2ProfileThickness, 0]) {
                UC2ProfileX(kUC2CubeSize, 90);
        }

        // Two short bars going across
        translate([0, 0, 0]) {
                UC2ProfileY(kUC2CubeSize, 0);
        }
        translate([kUC2CubeSize - kUC2ProfileThickness, 0, 0]) {
                UC2ProfileY(kUC2CubeSize, 90);
        }
        
        // Four vertical bars on the corners
        translate([0, 0, 0]) {
                UC2VerticalBar(0);
        }
        translate([0, kUC2CubeSize - kUC2ProfileThickness, 0]) {
                UC2VerticalBar(90);
        }
        translate([kUC2CubeSize - kUC2ProfileThickness,
                   kUC2CubeSize - kUC2ProfileThickness,
                   0]) {
                UC2VerticalBar(180);
        }
        translate([kUC2CubeSize - kUC2ProfileThickness, 0, 0]) {
                UC2VerticalBar(270);
        }
    }
}

module _UC2ScrewHoles()
{
    union() {        
        translate([kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset,
                   - 0.001]) {
                UC2M3Volume();
        }
        translate([kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        translate([kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        translate([kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        
        translate([kUC2M5OffsetX,
                   kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetY,
                   kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetX,
                   kUC2CubeSize - kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetY,
                   kUC2CubeSize - kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetX,
                   kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetY,
                   kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetX,
                   kUC2CubeSize - kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetY,
                   kUC2CubeSize - kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
    }    
}

module UC2ScrewHoles(bottomUp=true)
{
    if (bottomUp)
        _UC2ScrewHoles();
    else 
        mirror([0, 0, 1]) _UC2ScrewHoles();        
}

module UC2RemoveScrewHoles(bottomUp=true)
{
    difference() {
        children(0);
        UC2ScrewHoles(bottomUp);
    }    
}

module UC2CubeBottom()
{
    UC2RemoveScrewHoles() {
        UC2CubeBottomWithoutHoles();
    }                
}

module UC2CubeTopWithoutHoles()
{
    union() {
        // Two long bars going back to front
        translate([0, 0, 0]) {
                UC2ProfileX(kUC2CubeSize, 0);
        }
        translate([0, kUC2CubeSize-kUC2ProfileThickness, 0]) {
                UC2ProfileX(kUC2CubeSize, 90);
        }

        // Two short bars going across
        translate([0, 0, 0]) {
                UC2ProfileY(kUC2CubeSize, 0);
        }
        translate([kUC2CubeSize-kUC2ProfileThickness, 0, 0]) {
                UC2ProfileY(kUC2CubeSize, 90);
        }
    }
}

module UC2CubeTopUpsideDown()
{
    difference() {
        UC2CubeTopWithoutHoles();
        
        translate([kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        translate([kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        translate([kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        translate([kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   -0.001]) {
                UC2M3Volume();
        }
        
        translate([kUC2M5OffsetX,
                   kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetY,
                   kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetX,
                   kUC2CubeSize - kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2M5OffsetY,
                   kUC2CubeSize - kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetX,
                   kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetY,
                   kUC2M5OffsetX, -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetX,
                   kUC2CubeSize - kUC2M5OffsetY,
                   -0.001]) {
                UC2M5Volume();
        }
        translate([kUC2CubeSize - kUC2M5OffsetY,
                   kUC2CubeSize - kUC2M5OffsetX,
                   -0.001]) {
                UC2M5Volume();
        }
    }
}

module UC2CubeTop()
{
    translate([0, kUC2CubeSize, 0]) {
        rotate([180, 0, 0]) {
            UC2CubeTopUpsideDown();
        }
    }
}

//translate([0, 0, kUC2HeightBottom + kUC2ProfileThickness]) UC2CubeTop();
*UC2CubeBottom();
*UC2CubeTop();