/**
Tools to help make emergency masks out of fabric.
Templates, forms, etc.

To print different things, basically just solo different elements.  (Put a "!" in front
of the element in question.)  Not super well organized, sorry.
*/

use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>

$fn=60;
BIG = 1000;

INCH = 25.4;

//SX = 3*INCH;
//SY = 2*INCH;
SX = 9*INCH;
SY = 6*INCH;
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

* union() { // Mask template
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
  intersection() { // Frame
    difference() {
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
    linear_extrude(height=BIG,center=true) {
      cmirror([1,0,0]) channel(from=[-SX/2-CUT_T/2,-BIG],to=[-SX/2-CUT_T/2,BIG],d=FRAME_T*2);
      channel(from=[-SX/2-CUT_T/2,-BIG],to=[-SX/2-CUT_T/2,BIG],d=FRAME_T*2);
      channel(from=[-BIG,SY/2+CUT_T/2],to=[BIG,SY/2+CUT_T/2],d=FRAME_T*2);
      if (!FRAME_JOINED) {
        mirror([0,1,0]) channel(from=[-BIG,SY/2+CUT_T/2],to=[BIG,SY/2+CUT_T/2],d=FRAME_T*2);
      }
    }
  }
}

union() { // Pleat rack
  RACK_SZ = 20;
  RACK_T = 1.5;
  HOOK_L = PLEAT_SY; //TODO Correct?
  HOOK_INTERVAL = 2*INCH;
  
  CLOTH_SPACE = 1;
  HOOK_GAP = RACK_T + CLOTH_SPACE;
  HOOK_OUT = HOOK_GAP + RACK_T;
  
  STICK_OUTY_BIT_A_LENGTH = HOOK_L;

  *translate([-20,0,0]) union() { // Hook test
    linear_extrude(height=RACK_SZ) {
      for (ps = [
          [[0,0],[0,HOOK_L*1.5*2]],
          [[0,HOOK_L*1.5],[HOOK_OUT,HOOK_L*1.5]],
          [[HOOK_OUT,HOOK_L*1.5],[HOOK_OUT,HOOK_L*1.5-HOOK_L]],
        ]) {
        channel(from=ps[0],to=ps[1],d=RACK_T,cap="square");
      }
    }
  }
  
  BRIDGE_SY = HOOK_GAP;
  BRIDGE_SX = 20;
  
  BRIDGE_LENGTH = 7.5*INCH;
  
  PIER_A_SX = 2*INCH; //TODO ?
  PIER_B_SX = PIER_A_SX-HOOK_L+RACK_T+CLOTH_SPACE/2;
  
  HANDLE_A_SX = 40; //TODO ???
  HANDLE_B_SX = 70; //TODO ???

  HINGE_SLOP = 1;
  HINGE_T = BRIDGE_SY;
  HINGE_A_L = 40; //TODO ???
  HINGE_B_L = 40; //TODO ???
  
  translate([0,70,0])
  union() { // Rack A
    linear_extrude(height=RACK_SZ) {
      for (ps = [
          [[0,-HOOK_OUT],[-PIER_A_SX,-HOOK_OUT]],
          [[-PIER_A_SX+HOOK_L,-HOOK_OUT],[-PIER_A_SX+HOOK_L,0]],
          [[-PIER_A_SX+HOOK_L,0],[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX,0]],
          [[-PIER_A_SX+HOOK_L-HOOK_INTERVAL,0],[-PIER_A_SX+HOOK_L-HOOK_INTERVAL,-HOOK_OUT]],
          [[-PIER_A_SX+HOOK_L-HOOK_INTERVAL,-HOOK_OUT],[-PIER_A_SX-HOOK_INTERVAL,-HOOK_OUT]],
      
          // Base bridge
          [[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX,0],[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX,BRIDGE_SY+RACK_T]],
          [[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX,BRIDGE_SY+RACK_T],[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX+BRIDGE_SX+RACK_T,BRIDGE_SY+RACK_T]],
          [[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX+BRIDGE_SX+RACK_T,BRIDGE_SY+RACK_T],[-PIER_A_SX-HOOK_INTERVAL-HANDLE_A_SX+BRIDGE_SX+RACK_T,0]],
      
          // Pier bridge
          [[-PIER_A_SX+HOOK_L,-HOOK_OUT],[-PIER_A_SX+HOOK_L,-HOOK_OUT+BRIDGE_SY+RACK_T]],
          [[-PIER_A_SX+HOOK_L,-HOOK_OUT+BRIDGE_SY+RACK_T],[-PIER_A_SX+HOOK_L+BRIDGE_SX+RACK_T,-HOOK_OUT+BRIDGE_SY+RACK_T]],
          [[-PIER_A_SX+HOOK_L+BRIDGE_SX+RACK_T,-HOOK_OUT+BRIDGE_SY+RACK_T],[-PIER_A_SX+HOOK_L+BRIDGE_SX+RACK_T,-HOOK_OUT]],
        ]) {
        channel(from=ps[0],to=ps[1],d=RACK_T,cap="square");
      }
    }
  }
  
  translate([0,50,0])
  union() { // Rack B
    linear_extrude(height=RACK_SZ) {
      for (ps = [
          // Stem
          [[0,0],[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX,0]],

          // Hook
          [[-PIER_B_SX-HOOK_L,0],[-PIER_B_SX-HOOK_L,HOOK_OUT]],
          [[-PIER_B_SX-HOOK_L,HOOK_OUT],[-PIER_B_SX,HOOK_OUT]],

          // Hook
          [[-PIER_B_SX-HOOK_INTERVAL-HOOK_L,0],[-PIER_B_SX-HOOK_INTERVAL-HOOK_L,HOOK_OUT]],
          [[-PIER_B_SX-HOOK_INTERVAL-HOOK_L,HOOK_OUT],[-PIER_B_SX-HOOK_INTERVAL,HOOK_OUT]],
      
          // Base bridge
          [[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX,0],[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX,BRIDGE_SY+RACK_T]],
          [[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX,BRIDGE_SY+RACK_T],[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX+BRIDGE_SX+RACK_T,BRIDGE_SY+RACK_T]],
          [[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX+BRIDGE_SX+RACK_T,BRIDGE_SY+RACK_T],[-PIER_B_SX-HOOK_INTERVAL-HANDLE_B_SX+BRIDGE_SX+RACK_T,0]],

          // Pier bridge
          [[-PIER_B_SX-HOOK_L,0],[-PIER_B_SX-HOOK_L,BRIDGE_SY+RACK_T]],
          [[-PIER_B_SX-HOOK_L,BRIDGE_SY+RACK_T],[-PIER_B_SX-HOOK_L-BRIDGE_SX-RACK_T,BRIDGE_SY+RACK_T]],
          [[-PIER_B_SX-HOOK_L-BRIDGE_SX-RACK_T,BRIDGE_SY+RACK_T],[-PIER_B_SX-HOOK_L-BRIDGE_SX-RACK_T,0]],
        ]) {
        channel(from=ps[0],to=ps[1],d=RACK_T,cap="square");
      }
    }
  }

  //// Bridges

  translate([0,-10,0]) mirror([0,1,0])
  union() { // Bridge A
    linear_extrude(height=BRIDGE_SX) { // Bridge
      channel(from=[-BRIDGE_SY*3/2,0],to=[-BRIDGE_LENGTH+BRIDGE_SY*3/2,0],d=BRIDGE_SY,cap="sharp");
    }
    linear_extrude(height=BRIDGE_SX+RACK_T) { // Stopper
      STOPPER_T = BRIDGE_SY;
      channel(from=[-RACK_SZ-STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-RACK_SZ-STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
      channel(from=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
    }
    translate([-BRIDGE_LENGTH/2,0,0]) cmirror([1,0,0]) translate([BRIDGE_LENGTH/2,0,0]) {
      translate([-RACK_SZ-HINGE_T/2-HINGE_T-HINGE_SLOP/2,-BRIDGE_SY/2-RACK_T,HINGE_A_L+BRIDGE_SX]) translate([0,BRIDGE_SX/2,0]) scale([1,1,3]) rotate([0,45,0]) cube([HINGE_T*sqrt(1/2),BRIDGE_SX,HINGE_T*sqrt(1/2)],center=true);
      linear_extrude(height=HINGE_A_L+BRIDGE_SX) { // Hinge ball
        channel(from=[-RACK_SZ-HINGE_T/2-HINGE_T-HINGE_SLOP/2,-BRIDGE_SY/2-RACK_T],to=[-RACK_SZ-HINGE_T/2-HINGE_T-HINGE_SLOP/2,-BRIDGE_SY/2-RACK_T+BRIDGE_SX],d=HINGE_T,cap="none");
      }
    }
  }

  union() { // Bridge B
    linear_extrude(height=BRIDGE_SX) { // Bridge
      channel(from=[-BRIDGE_SY*3/2,0],to=[-BRIDGE_LENGTH+BRIDGE_SY*3/2,0],d=BRIDGE_SY,cap="sharp");
    }
    linear_extrude(height=BRIDGE_SX+RACK_T) { // Stopper
      STOPPER_T = BRIDGE_SY;
      channel(from=[-RACK_SZ-STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-RACK_SZ-STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
      channel(from=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
    }
    translate([-BRIDGE_LENGTH/2,0,0]) cmirror([1,0,0]) translate([BRIDGE_LENGTH/2,0,0]) translate([0,BRIDGE_SY/2,0])
     linear_extrude(height=BRIDGE_SX) { // Hinge socket
      channel(from=[-RACK_SZ-HINGE_T/2,0],to=[-RACK_SZ-HINGE_T/2,HINGE_B_L/2],d=HINGE_T,cap="none");
      channel(from=[-RACK_SZ-HINGE_T/2,HINGE_B_L/2],to=[-RACK_SZ-HINGE_T/2,HINGE_B_L],d=HINGE_T,cap="sharp");
       
      channel(from=[-RACK_SZ-HINGE_T/2-HINGE_T*2-HINGE_SLOP,0],to=[-RACK_SZ-HINGE_T/2-HINGE_T*2-HINGE_SLOP,HINGE_B_L/2],d=HINGE_T,cap="none");
      channel(from=[-RACK_SZ-HINGE_T/2-HINGE_T*2-HINGE_SLOP,HINGE_B_L/2],to=[-RACK_SZ-HINGE_T/2-HINGE_T*2-HINGE_SLOP,HINGE_B_L],d=HINGE_T,cap="sharp");
    }
  }

  translate([0,-40,0]) cmirror([0,1,0]) translate([0,5,0])
  union() { // Pier bridge
    linear_extrude(height=BRIDGE_SX) { // Bridge
      channel(from=[-BRIDGE_SY*3/2,0],to=[-BRIDGE_LENGTH+BRIDGE_SY*3/2,0],d=BRIDGE_SY,cap="sharp");
    }
    linear_extrude(height=BRIDGE_SX+RACK_T) { // Stopper
      STOPPER_T = BRIDGE_SY;
      channel(from=[-RACK_SZ-STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-RACK_SZ-STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
      channel(from=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
    }
  }
}

*union() { // Ruler spacer
  RULER_WIDTH = 1*INCH;
  RULER_T = TEMPLATE_SZ/2;
  cube([SX,RULER_WIDTH, RULER_T],center=true);
  cmirror([1,0,0]) translate([-SX/2,0,RULER_T/2]) {
    halfPyramid(RULER_T);
  }
}
