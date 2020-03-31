/**
Tools to help make emergency masks out of fabric.
Templates, forms, etc.
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>

$fn=60;
BIG = 1000;

INCH = 25.4;

SX = 9*INCH;
STEP_SZ = 2;
STEP_SZ_BIG = STEP_SZ*1.5;
PLEAT_SY = 0.25*INCH;
MIDDLE_SY = 1.75*INCH;
LIP = 3;

BRACE_SX = LIP/2;
VOID_INTERVAL = 10.5;

//TODO Step z-gap

module centerPleat() {
  difference() {
    union() {
      translate([0,0,STEP_SZ/2]) cube([SX,MIDDLE_SY,STEP_SZ],center=true);
      translate([0,0,-STEP_SZ_BIG/2]) cube([SX,MIDDLE_SY-PLEAT_SY*2,STEP_SZ_BIG],center=true);
    }
    intersection() {
      difference() {
        cube(BIG,center=true);
        for (dx=[-20:1:20]) translate([dx*VOID_INTERVAL,0,0]) cube([BRACE_SX,BIG,BIG],center=true);
      }
      cube([SX-LIP*2,MIDDLE_SY-PLEAT_SY*2-LIP*2,BIG],center=true);
    }
  }
}

union() { // Pleat steps
  // Center
  centerPleat();
  
  // Edges
  cmirror([0,1,0])
  translate([0,MIDDLE_SY*1.1,0]) union() {
    difference() {
      mirror([0,0,1]) union() {
        centerPleat();
        translate([0,0,-(STEP_SZ_BIG-STEP_SZ)/2]) cube([SX,LIP*2,STEP_SZ+STEP_SZ_BIG],center=true);
      }
      OYp();
    }
  }
}