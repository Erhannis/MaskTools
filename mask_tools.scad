/**
Tools to help make emergency masks out of fabric.
Templates, forms, etc.
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>

$fn=60;
BIG = 1000;

INCH = 25.4;

SX = 3*INCH;//9*INCH;
SY = 2*INCH;//6*INCH;
STEP_SZ = 2;
STEP_SZ_BIG = STEP_SZ*1.5;
PLEAT_SY = 0.25*INCH;
MIDDLE_SY = 1.75*INCH;
LIP = 3;
PLEAT_STEPS_INSET = 0.5*INCH; // Like, how much fabric should hang off the ends

BRACE_SX = LIP/2;
VOID_INTERVAL = 10.5;

TEMPLATE_SZ = 5; //TODO Might need to be bigger

module centerPleat() {
  difference() {
    union() {
      translate([0,0,STEP_SZ/2]) cube([SX,MIDDLE_SY,STEP_SZ],center=true);
      translate([0,0,-STEP_SZ_BIG/2]) cube([SX,MIDDLE_SY-PLEAT_SY*2,STEP_SZ_BIG],center=true);
    }
    *intersection() {
      difference() {
        cube(BIG,center=true);
        for (dx=[-20:1:20]) translate([dx*VOID_INTERVAL,0,0]) cube([BRACE_SX,BIG,BIG],center=true);
      }
      cube([SX-LIP*2,MIDDLE_SY-PLEAT_SY*2-LIP*2,BIG],center=true);
    }
  }
}

*union() { // Pleat steps
  // Center
  centerPleat();
  
  // Edges
  //cmirror([0,1,0])
  *translate([0,MIDDLE_SY*1.1,0]) union() {
    difference() {
      mirror([0,0,1]) union() {
        centerPleat();
        translate([0,0,-(STEP_SZ_BIG-STEP_SZ)/2]) cube([SX,LIP*2,STEP_SZ+STEP_SZ_BIG],center=true);
      }
      OYp();
    }
  }
}

union() { // Mask template
  ST_SX = SX-0.25*INCH*2;
  ST_SY = SY-0.25*INCH*2;
  MARKER_D = 1.5;
  BRIDGE_D = 2;
  CORNER_BRIDGE_D = 3*BRIDGE_D;
  SOUTH_KERF = MARKER_D*0.4; // This means the south edge is slightly short.  It's also finely calibrated to not mess up upside-down printing (at slight expense to accuracy).
  difference() { // Template
    translate([0,SOUTH_KERF/2,TEMPLATE_SZ/2]) cube([SX,SY-SOUTH_KERF,TEMPLATE_SZ], center=true);
    if (SOUTH_KERF > 0) {
      translate([0,-SY/2+SOUTH_KERF,TEMPLATE_SZ]) rotate([0,45,0]) cube([TEMPLATE_SZ*0.5,(SX-ST_SX)/2,TEMPLATE_SZ*0.5],center=true);
    }
    cmirror([1,0,0]) for (p=[[[-0.5*ST_SX,-0.5*ST_SY+CORNER_BRIDGE_D],[-0.5*ST_SX,0*ST_SY-BRIDGE_D]],[[-0.5*ST_SX,0*ST_SY+BRIDGE_D],[-0.5*ST_SX,0.5*ST_SY-CORNER_BRIDGE_D]]]) {
      linear_extrude(height=BIG,center=true) {
        channel(from=p[0],to=p[1],d=MARKER_D,cap="none");
      }
      translate([0,0,-MARKER_D/2]) translate(p[0]) rotate([0,-45,0]) cube([BIG,p[1][1]-p[0][1],BIG]);
    }
    cmirror([0,1,0]) for (p=[[[-0.5*ST_SX+CORNER_BRIDGE_D,-0.5*ST_SY],[-0.166*ST_SX-BRIDGE_D,-0.5*ST_SY]],[[-0.166*ST_SX+BRIDGE_D,-0.5*ST_SY],[0.166*ST_SX-BRIDGE_D,-0.5*ST_SY]],[[0.166*ST_SX+BRIDGE_D,-0.5*ST_SY],[0.5*ST_SX-CORNER_BRIDGE_D,-0.5*ST_SY]]]) {
      linear_extrude(height=BIG,center=true) {
        channel(from=p[0],to=p[1],d=MARKER_D,cap="none");
      }
      translate([0,0,-MARKER_D/2]) translate(p[0]) rotate([45,0,0]) cube([p[1][0]-p[0][0],BIG,BIG]);
    }
  }
  
  
  // Pick one of these
  //CUTTER = "xacto";
  CUTTER = "roller";
  
  ROLLER_DIAM = 45.6;
  
  FRAME_JOINED = true;
  CUT_T = 1;
  CUT_OVERSHOT = 3;
  FRAME_T = 5;
  FRAME_T0 = (CUTTER == "xacto" ? 5 : 15) + CUT_OVERSHOT;
  ENTRY_SLOT_LENGTH = ROLLER_DIAM * 0.25;
  ENTRY_SLOT_DEPTH = CUT_T*2;
  difference() { // Frame
    translate([0,0,TEMPLATE_SZ/2]) cube([SX+FRAME_T0*2,SY+FRAME_T0*2,TEMPLATE_SZ], center=true);
    translate([0,SOUTH_KERF/2,0]) cube([SX,SY-SOUTH_KERF,BIG], center=true);
    cmirror([1,0,0]) translate([SX/2,0,-SY/2-CUT_OVERSHOT]) rotate([45,0,0]) cube([CUT_T,BIG,BIG]);
    if (CUTTER == "roller") { // This isn't quite pretty code, just slapping circles over a presumably steeper angle.  Eh.
      cmirror([1,0,0]) cmirror([0,1,0]) translate([-SX/2,-SY/2-CUT_OVERSHOT,0]) rotate([0,-90,0]) translate([ROLLER_DIAM/2,0,0]) cylinder(d=ROLLER_DIAM,h=CUT_T,center=false);
    }
    if (FRAME_JOINED) {
      translate([0,SY/2,-SX/2-CUT_OVERSHOT]) rotate([0,-45,0]) cube([BIG,CUT_T,BIG]);
      mirror([0,1,0]) translate([0,-SY/2+BIG/2,0]) cube([SX-FRAME_T0*2,BIG,BIG],center=true);
      if (CUTTER == "roller") { // This isn't quite pretty code, just slapping circles over a presumably steeper angle.  Eh.
        mirror([0,1,0]) cmirror([1,0,0]) translate([-SX/2-CUT_OVERSHOT,-SY/2,0]) rotate([90,0,0]) translate([0,ROLLER_DIAM/2,0]) cylinder(d=ROLLER_DIAM,h=CUT_T,center=false);
      }
    } else {
      cmirror([0,1,0]) translate([0,SY/2,-SX/2-CUT_OVERSHOT]) rotate([0,-45,0]) cube([BIG,CUT_T,BIG]);
      if (CUTTER == "roller") { // This isn't quite pretty code, just slapping circles over a presumably steeper angle.  Eh.
        cmirror([0,1,0]) cmirror([1,0,0]) translate([-SX/2-CUT_OVERSHOT,-SY/2,0]) rotate([90,0,0]) translate([0,ROLLER_DIAM/2,0]) cylinder(d=ROLLER_DIAM,h=CUT_T,center=false);
      }
    }
    union() { // Entry slots
      if (FRAME_JOINED) {
        cmirror([1,0,0]) translate([-SX/2,SY/2,TEMPLATE_SZ]) difference() {
          rotate([0,45,0]) cube([ENTRY_SLOT_DEPTH*sqrt(2),ENTRY_SLOT_LENGTH,ENTRY_SLOT_DEPTH*sqrt(2)],center=true);
          OXp();
        }
        cmirror([1,0,0]) translate([-SX/2,SY/2,TEMPLATE_SZ]) difference() {
          rotate([45,0,0]) cube([ENTRY_SLOT_LENGTH,ENTRY_SLOT_DEPTH*sqrt(2),ENTRY_SLOT_DEPTH*sqrt(2)],center=true);
          OYm();
        }
      } else {
        cmirror([0,1,0]) cmirror([1,0,0]) translate([-SX/2,SY/2,TEMPLATE_SZ]) difference() {
          rotate([0,45,0]) cube([ENTRY_SLOT_DEPTH*sqrt(2),ENTRY_SLOT_LENGTH,ENTRY_SLOT_DEPTH*sqrt(2)],center=true);
          OXp();
        }
        cmirror([0,1,0]) cmirror([1,0,0]) translate([-SX/2,SY/2,TEMPLATE_SZ]) difference() {
          rotate([45,0,0]) cube([ENTRY_SLOT_LENGTH,ENTRY_SLOT_DEPTH*sqrt(2),ENTRY_SLOT_DEPTH*sqrt(2)],center=true);
          OYm();
        }
      }
    }
    cmirror([1,0,0]) cmirror([0,1,0]) translate([SX/2,SY/2,0]) cube([CUT_T,CUT_T,BIG]);
  }
}
