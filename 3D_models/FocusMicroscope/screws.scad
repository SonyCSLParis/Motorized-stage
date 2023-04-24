include <units.scad>

// Screws
kDiameterScrew = 0;
kDiameterHead = 1;
kHeightHead = 2;

// Diameter screw, Diameter head, Height head 
kM25Dimensions = [2.5*mm, 4.5*mm, 2.5*mm];
kM3Dimensions = [3*mm, 5.5*mm, 3*mm];
kM4Dimensions = [4*mm, 7*mm, 4*mm];

// Nuts
kNutHeight = 0;
kNutDiameter = 1;

// Height, Diameter 
kM25LockNutDimensions = [3*mm, 5.51*mm];
kM3LockNutDimensions = [4*mm, 6.01*mm];
kM4LockNutDimensions = [5*mm, 7.66*mm];

kM25NutDimensions = [2*mm, 5.51*mm];
kM3NutDimensions = [2.4*mm, 6.01*mm];
kM4NutDimensions = [3.2*mm, 7.66*mm];


module _orient(orientation)
{
    if (orientation[2] == 1) {
        rotate([0, 180, 0])
        children(0);
    } else if (orientation[2] == -1) {
        rotate([0, 0, 0])
        children(0);
    } else if (orientation[0] == 1) {
        rotate([0, -90, 0])
        children(0);
    } else if (orientation[0] == -1) {
        rotate([0, 90, 0])
        children(0);
    } else if (orientation[1] == 1) {
        rotate([90, 0, 0])
        children(0);
    } else if (orientation[1] == -1) {
        rotate([-90, 0, 0])
        children(0);
    } 
}

module _Screw(dimensions, length, extraScrewRadius=0, extraHeadRadius=0, extraHeadHeight=0)
{
    d_screw = dimensions[kDiameterScrew];
    d_head = dimensions[kDiameterHead];
    h_head = dimensions[kHeightHead];
    
    color("lightgrey")
    union() {
        cylinder(d = d_head + extraHeadRadius,
                 h = h_head + extraHeadHeight,
                 $fn=360);

        translate([0, 0, -length]) {
            cylinder(d = d_screw + extraScrewRadius,
                     h = length + 0.01,
                     $fn=360);
        }
    }
}

module M25(length, orientation, extraScrewRadius=0, extraHeadRadius=0,   extraHeadHeight=0)
{
    _orient(orientation) {
        _Screw(kM25Dimensions, length, extraScrewRadius, 
                extraHeadRadius,   extraHeadHeight);
    }
}

module M3(length, orientation, extraScrewRadius=0, extraHeadRadius=0,   extraHeadHeight=0)
{
    _orient(orientation) {
        _Screw(kM3Dimensions, length, extraScrewRadius, 
                extraHeadRadius,   extraHeadHeight);
    }
}

module M4(length, orientation, extraScrewRadius=0, extraHeadRadius=0,   extraHeadHeight=0)
{
    _orient(orientation) {
        _Screw(kM4Dimensions, length, extraScrewRadius, 
                extraHeadRadius,   extraHeadHeight);
    }
}

////////////////////////////////

module _LockNut(dimensions, extraRadius, extraHeight)
{
    color("lightgrey")
    cylinder(d = dimensions[kNutDiameter] + extraRadius, 
             h = dimensions[kNutHeight] + extraHeight, $fn=6);
}

module M25LockNut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _LockNut(kM25LockNutDimensions, extraRadius, extraHeight);
    }
}

module M3LockNut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _LockNut(kM3LockNutDimensions, extraRadius, extraHeight);
    }
}

module M4LockNut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _LockNut(kM4LockNutDimensions, extraRadius, extraHeight);
    }
}

////////////////////////////////

module _Nut(dimensions, extraRadius, extraHeight)
{
    color("lightgrey")
    cylinder(d = dimensions[kNutDiameter] + extraRadius, 
             h = dimensions[kNutHeight] + extraHeight, $fn=6);
}

module M25Nut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _Nut(kM25NutDimensions, extraRadius, extraHeight);
    }
}

module M3Nut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _Nut(kM3NutDimensions, extraRadius, extraHeight);
    }
}

module M4Nut(orientation, extraRadius=0, extraHeight=0)
{
    _orient(orientation) {
        _Nut(kM4NutDimensions, extraRadius, extraHeight);
    }
}

*M3Nut(-X);
