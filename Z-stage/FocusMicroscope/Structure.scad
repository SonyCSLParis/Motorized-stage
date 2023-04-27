include <units.scad>
include <UC2.scad>
include <LinearSlider.scad>
include <screws.scad>


kSpacingLinearSlider = 1*mm;

kSwitchSizeX = 10*mm;
kSwitchSizeY = 12.8*mm;
kSwitchSizeZ = 5.8*mm;
kSwitchOffsetHoleX = 5*mm;
kM2HeadHeight = 2*mm;
kM2ScrewDiameter = 2*mm;

kFrontPanelDepth = 5*mm;
kFrontPanelSpacing = 1.5*mm;

kSampleHolderDepth = 6*mm;
kSampleHolderRailLength = 30*mm;
kSampleHolderRailOffset = 8*mm;

kLinearSliderOffsetZ = kUC2ProfileThickness + kSpacingLinearSlider;

module M3Volume(length, headHeight=kM3HeightHead)
{
    union() {
        cylinder(r = kM3DiameterHead / 2 + 0.2,
                 h = headHeight + 0.01,
                 $fn=360);
        
        translate([0, 0, -length]) {
                cylinder(r = kM3DiameterScrew / 2 + 0.1,
                         h = length + 0.01,
                         $fn=360);
        }
    }
}

function computeAvailableHeight() 
    = kUC2CubeSize - kUC2ProfileThickness - kSpacingLinearSlider;

function computeDistanceBottomToTopSlider() 
    = kHeight - kOffsetMotorAndMotorPlate - kMotorHeight/2 + kSliderOffsetAxis;

function computeSocketHeight() 
    = computeAvailableHeight() - computeDistanceBottomToTopSlider();

module FixationSocketVolume(length, width, height)
{
    union() {
        cube([length, width, height]);
        
        translate([-kFrontPlateDepth, 
                   -(kUC2CubeSize - width) / 2, 
                   height]) 
        {
            translate([0, 0, -3.5*mm]) 
                cube([kUC2CubeSize, kUC2CubeSize, 3.5*mm]);
        
            translate([0, 0, -kUC2ProfileThickness]) 
                cube([kUC2CubeSize, kUC2ProfileThickness, kUC2ProfileThickness]);
            translate([0, kUC2CubeSize-kUC2ProfileThickness, -kUC2ProfileThickness]) 
                cube([kUC2CubeSize, kUC2ProfileThickness, kUC2ProfileThickness]);
        }
    }
}

module FixationSocket()
{
    // The "socket" is the extrusion to which the linear slider is attached.
    // Here we compute its dimensions and position
    socketLength = kSliderLength; // imported from LinerSlider.scad
    socketWidth = kSliderWidth;
    socketHeight = computeSocketHeight();

    difference() {
        FixationSocketVolume(socketLength, socketWidth, socketHeight);

        lengthScrew = 16*mm;
        offsetScrewDepth = 2*mm;
        fixationScrewOffsetX = (socketLength - kSliderDistanceHoles) / 2;
        fixationScrewOffsetY = (kSliderWidth - kSliderDistanceHoles) / 2;
        fixationScrewOffsetZ = socketHeight - kM3HeightHead - offsetScrewDepth;

        // Fixation screw holes
        translate([fixationScrewOffsetX,
                   fixationScrewOffsetY,
                   fixationScrewOffsetZ]) {
                M3Volume(lengthScrew,
                         kM3HeightHead + offsetScrewDepth);
        }
        translate([socketLength - fixationScrewOffsetX,
                   fixationScrewOffsetY,
                   fixationScrewOffsetZ]) {
                M3Volume(lengthScrew, kM3HeightHead + offsetScrewDepth);
        }
        translate([socketLength - fixationScrewOffsetX,
                   socketWidth - fixationScrewOffsetY,
                   fixationScrewOffsetZ]) {
                M3Volume(lengthScrew, kM3HeightHead + offsetScrewDepth);
        }
        translate([fixationScrewOffsetX,
                   socketWidth - fixationScrewOffsetY,
                   fixationScrewOffsetZ]) {
                M3Volume(lengthScrew, kM3HeightHead + offsetScrewDepth);
        }
        
        // Limit switches
        
        // Cut-out space to house the limit switches
        
        translate([-0.1*mm, (socketWidth - kSwitchSizeY - 0.2)/2, -0.1*mm]) {
                cube([socketLength + 0.2*mm,
                      kSwitchSizeY,
                      kSwitchSizeZ + kM2HeadHeight + 0.2*mm]);
        }
        
        // Hole for wires limit switches
        
        openingSize = 10*mm;
        translate([(socketLength - openingSize) / 2, -0.02, -0.1*mm]) {
                cube([openingSize, socketWidth/2+0.02*mm, kSwitchSizeZ+0.2*mm]);
        }
        
        // Thru-holes for M2 screws to fix the limit switches
        
        translate([5*mm,
                   socketWidth/2 - 6.5*mm/2,
                   -0.01]) {
                cylinder(r=kM2ScrewDiameter/2, h=socketHeight+0.02, $fn=360);
        }
        translate([5*mm,
                   socketWidth/2 + 6.5*mm/2,
                   -0.01]) {
                cylinder(r=kM2ScrewDiameter/2, h=socketHeight+0.02, $fn=360);
        }
        translate([socketLength - 5*mm,
                   socketWidth/2 - 6.5*mm/2,
                   -0.01]) {
                cylinder(r=kM2ScrewDiameter/2, h=socketHeight+0.02, $fn=360);
        }
        translate([socketLength - 5*mm,
                   socketWidth/2 + 6.5*mm/2,
                   -0.01]) {
                cylinder(r=kM2ScrewDiameter/2, h=socketHeight+0.02, $fn=360);
        }

        // Hexagone cut-out for the M2 nuts to fix the limit switches
        offsetNut = 1*mm;
        translate([5*mm,
                   socketWidth/2 - 6.5*mm/2,
                   socketHeight-kM2HeadHeight-offsetNut+0.01]) {
            cylinder(d=4.9*mm, h=kM2HeadHeight+offsetNut+0.02, $fn=6);
        }
        
        translate([5*mm,
                   socketWidth/2 + 6.5*mm/2,
                   socketHeight-kM2HeadHeight-offsetNut+0.01]) {
            cylinder(d=4.9*mm, h=kM2HeadHeight+offsetNut+0.02, $fn=6);
        }
        
        translate([socketLength - 5*mm,
                   socketWidth/2 - 6.5*mm/2,
                   socketHeight-kM2HeadHeight-offsetNut+0.01]) {
            cylinder(d=4.9*mm, h=kM2HeadHeight+offsetNut+0.02, $fn=6);
        }
        
        translate([socketLength - 5*mm,
                   socketWidth/2 + 6.5*mm/2,
                   socketHeight-kM2HeadHeight-offsetNut+0.01]) {
            cylinder(d=4.9*mm, h=kM2HeadHeight+offsetNut+0.02, $fn=6);
        }
                

    }
}

module StructureTop()
{
    UC2RemoveScrewHoles(false) {
        // Move corner in (0,0,0)
        translate([kFrontPlateDepth, 
                   (kUC2CubeSize - kSliderWidth) / 2, 
                  -computeSocketHeight()])
            FixationSocket();
    }
}

module _FrontPanel()
{
    translate([0, 0, kFrontPanelSpacing]) {
            cube([kFrontPanelDepth, kUC2CubeSize, kUC2CubeSize - kFrontPanelSpacing]);
    }
}

module _AddBallHoles()
{
    difference() {
        children(0);
        // Holes for magnetic balls
        translate([-0.1*mm, kUC2M3ScrewOffset, kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
    }
}

module FrontPanel()
{
    dz_screw = kLinearSliderOffsetZ + kFrontPlateScrewHeadDiameter/2 + kFrontPlateScrewHeadOffset;
            
    difference() {
        union() {
            _FrontPanel();
                
            // Extrusion that fits over front panel
            dz = kUC2ProfileThickness + kSpacingLinearSlider + kFrontPlateHeight;
            translate([-kFrontPlateDepth - 0.1*mm,
                       (kUC2CubeSize - kSliderWidth) / 2,
                       dz]) {
                cube([kFrontPlateDepth + 0.1*mm, kSliderWidth, 6*mm]);
            }

            // Cylindric extrusion that fits in existing screw hole
            translate([-3, (kUC2CubeSize - kFrontPlateScrewDistance) / 2, dz_screw]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.9*mm, h=3.1*mm, $fn=360);
                }
            }
            
            // Cylindric extrusion that fits in existing screw hole
            translate([-3, (kUC2CubeSize + kFrontPlateScrewDistance) / 2, dz_screw]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.9*mm, h=3.1*mm, $fn=360);
                }
            }
        }

        // Holes for M3 screws
        translate([kM3HeightHead - 1*mm,
                   (kUC2CubeSize - kFrontPlateScrewDistance) / 2,
                   dz_screw]) {
                rotate([0, 90, 0]) {
                        M3Volume(12*mm, kM3HeightHead+1*mm+0.1);
                }
        }                
        translate([kM3HeightHead - 1*mm,
                   (kUC2CubeSize + kFrontPlateScrewDistance) / 2,
                   dz_screw]) {
                rotate([0, 90, 0]) {
                        M3Volume(12*mm, kM3HeightHead+1*mm+0.1);
                }
        }
        
        // Holes for magnetic balls
        translate([-0.1*mm, kUC2M3ScrewOffset, kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
        translate([-0.1*mm,
                   kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
                rotate([0, 90, 0]) {
                        cylinder(r=2.48, h=5.2, $fn=360);
                }
        }
    }
}

module _SampleHolder()
{
    translate([0, 0, kFrontPanelSpacing]) {
            cube([kSampleHolderDepth, kUC2CubeSize, kUC2CubeSize - kFrontPanelSpacing]);
    }
}

module _AddScrewHoles()
{
    difference() {
        children(0);
        // Holes for magnetic balls
        dx = kM3Dimensions[kHeightHead];
        translate([dx, kUC2M3ScrewOffset, kUC2M3ScrewOffset]) {
            M3(10*mm, X, 0.1*mm, 0.1*mm, 0.1*mm);
        }
        translate([dx,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2M3ScrewOffset]) {
            M3(10*mm, X, 0.1*mm, 0.1*mm, 0.1*mm);
        }
        translate([dx,
                   kUC2CubeSize - kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
            M3(10*mm, X, 0.1*mm, 0.1*mm, 0.1*mm);
        }
        translate([dx,
                   kUC2M3ScrewOffset,
                   kUC2CubeSize - kUC2M3ScrewOffset]) {
            M3(10*mm, X, 0.1*mm, 0.1*mm, 0.1*mm);
        }
    }
}

module SampleHolder()
{
    union() {
        _AddScrewHoles() {
            _SampleHolder();
        }
        
        translate([kFrontPanelDepth, 
                   kSampleHolderRailLength/2 + kUC2CubeSize/2, 
                   kSampleHolderRailOffset + kFrontPanelSpacing]) 
        rotate([90, 0, 0]) {
            linear_extrude(height = kSampleHolderRailLength) {
                import("SampleHolderRail.dxf", $fn=360); 
            }
        }   
        
        translate([kFrontPanelDepth, 
                   -kSampleHolderRailLength/2 + kUC2CubeSize/2, 
                   kUC2CubeSize - kSampleHolderRailOffset]) 
        rotate([-90, 0, 0]) {
            linear_extrude(height = kSampleHolderRailLength) {
                import("SampleHolderRail.dxf", $fn=360); 
            }
        }   

        ///////////////////////////////////////
    }
}


*FixationSocket();
*StructureTop();
*FrontPanel();
*SampleHolder();