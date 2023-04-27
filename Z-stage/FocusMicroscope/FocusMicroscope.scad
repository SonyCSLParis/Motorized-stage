include <units.scad>
include <LinearSlider.scad>
include <Structure.scad>

// X-position of the slider
// Note: The 3D model moves along the x-axis, but in the Arduino 
// code it moves along the z-axis.
x = 20;

slider_x = kUC2CubeSize - kFrontPlateDepth - kSliderLength - x;
slider_y = kUC2CubeSize/2;
slider_z = -kSliderOffsetAxis + kUC2CubeSize - computeSocketHeight();


UC2CubeBottom();
translate([kUC2CubeSize, kUC2CubeSize, kUC2CubeSize]) {
    rotate([0, 0, 180]) // FIXME
        StructureTop();
}

translate([slider_x, 0, 0]) {
    translate([0, slider_y, slider_z]) 
        LinearSlider(x);
    translate([kDistancePlates + kFrontPlateDepth, 0, 0])
        FrontPanel();
    translate([kDistancePlates + kFrontPlateDepth + kFrontPanelDepth, 0, 0])
        SampleHolder();
}
