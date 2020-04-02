/**
Tools to help make emergency masks out of fabric.
Templates, forms, etc.

To print different things, basically just solo different elements.  (Put a "!" in front
of the element in question.)  Not super well organized, sorry.

Printing:
EVERYTHING IS PRINTED AT -0.08mm HORIZONTAL EXPANSION.  (A Cura setting.)
  If this is merely ignored, almost certainly things will not fit together.
For speed, print without the top or bottom layers.
If you print anything at a 45* angle, e.g. to fit on a normal bed, you should
  make sure the infill crisscrosses the part, rather than running lengthwise and across -
  the part is stronger with crisscrossing infill.
  You may have to mess with Cura's "infill line directions".
I had trouble printing infill at 0.4mm layer height with a 0.4mm nozzle - Cura does some
  chicanery with the infill widths that overtaxes the printer, I think.
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
PLEAT_SY = 0.5*INCH;
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
  HOOK_INTERVAL_ADJUSTMENT = 0;
  HOOK_INTERVAL = 2.5*HOOK_L+HOOK_INTERVAL_ADJUSTMENT;
  
  CLOTH_SPACE = 2;
  HOOK_GAP = RACK_T + CLOTH_SPACE;
  HOOK_OUT = HOOK_GAP + RACK_T;
  
  *translate([-80,7,0]) union() { // Hook test
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
  PIER_BRIDGE_SX = BRIDGE_SX/2;
  
  BRIDGE_LENGTH = 7*INCH;
  
  PIER_A_SX = HOOK_L+BRIDGE_SX+RACK_T;
  PIER_B_SX = PIER_A_SX-HOOK_L+RACK_T+CLOTH_SPACE/2;
  
  HANDLE_A_SX = 54+(SY-6*INCH)/2-HOOK_INTERVAL_ADJUSTMENT/2;
  HANDLE_B_SX = 89+(SY-6*INCH)/2-HOOK_INTERVAL_ADJUSTMENT/2;

  HINGE_SLOP = 1;
  HINGE_T = BRIDGE_SY;
  HINGE_A_L = 40; //TODO ???
  HINGE_B_L = 40; //TODO ???
  
  IDLE_SLOT_T = (BRIDGE_SY+2*RACK_T)*1.2;
  IDLE_SLOT_DOWNSET = 5;
  IDLE_SLOT_DEPTH = BRIDGE_SX*0.6;
  
  CENTER_MARKING_SIZE = 1;
  
  translate([0,76,0]) ctranslate([0,10,0])
  difference() { // Rack A - print 2
    union() {
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
            [[-PIER_A_SX+HOOK_L,-HOOK_OUT+BRIDGE_SY+RACK_T],[-PIER_A_SX+HOOK_L+PIER_BRIDGE_SX+RACK_T,-HOOK_OUT+BRIDGE_SY+RACK_T]],
            [[-PIER_A_SX+HOOK_L+PIER_BRIDGE_SX+RACK_T,-HOOK_OUT+BRIDGE_SY+RACK_T],[-PIER_A_SX+HOOK_L+PIER_BRIDGE_SX+RACK_T,-HOOK_OUT]],
          ]) {
          channel(from=ps[0],to=ps[1],d=RACK_T,cap="square");
        }
      }
    }
    for (dy=[0,0.5,1]*RACK_SZ) { // Center marking
      translate([-(HOOK_L/2+PIER_B_SX+HOOK_INTERVAL/2),0,dy]) rotate([0,45,0]) cube([CENTER_MARKING_SIZE,BIG,CENTER_MARKING_SIZE],center=true);
    }
  }
  
  translate([0,52,0]) ctranslate([0,10,0])
  difference() { // Rack B - print 2
      union() {
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
          ]) {
          channel(from=ps[0],to=ps[1],d=RACK_T,cap="square");
        }
      }
    }
    for (dy=[0,0.5,1]*RACK_SZ) { // Center marking
      translate([-(HOOK_L/2+PIER_B_SX+HOOK_INTERVAL/2),0,dy]) rotate([0,45,0]) cube([CENTER_MARKING_SIZE,BIG,CENTER_MARKING_SIZE],center=true);
    }
  }

  //// Bridges

  translate([0,-10,0]) mirror([0,1,0])
  difference() { // Bridge A
    union() {
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
    for (dy=[0,0.5,1]*BRIDGE_SX) { // Center marking
      translate([-BRIDGE_LENGTH/2,0,dy]) rotate([0,45,0]) cube([CENTER_MARKING_SIZE,BIG,CENTER_MARKING_SIZE],center=true);
    }
  }

  difference() { // Bridge B
    union() {
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
    translate([0,HINGE_B_L-IDLE_SLOT_DOWNSET,BRIDGE_SX]) rotate([-30,0,0]) translate([0,0,-IDLE_SLOT_DEPTH]) translate([0,0,BIG/2]) cube([BIG,IDLE_SLOT_T,BIG],center=true);
    for (dy=[0,0.5,1]*BRIDGE_SX) { // Center marking
      translate([-BRIDGE_LENGTH/2,0,dy]) rotate([0,45,0]) cube([CENTER_MARKING_SIZE,BIG,CENTER_MARKING_SIZE],center=true);
    }
  }

  translate([0,-35,0])
  difference() { // Pier bridge
    union() {
      linear_extrude(height=PIER_BRIDGE_SX) { // Bridge
        channel(from=[-BRIDGE_SY*3/2,0],to=[-BRIDGE_LENGTH+BRIDGE_SY*3/2,0],d=BRIDGE_SY,cap="sharp");
      }
      linear_extrude(height=PIER_BRIDGE_SX+RACK_T) { // Stopper
        STOPPER_T = BRIDGE_SY;
        channel(from=[-RACK_SZ-STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-RACK_SZ-STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
        channel(from=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,-BRIDGE_SY/2-RACK_T],to=[-BRIDGE_LENGTH+RACK_SZ+STOPPER_T/2,BRIDGE_SY/2+RACK_T],d=STOPPER_T,cap="none");
      }
    }
    for (dy=[0,0.5,1]*PIER_BRIDGE_SX) { // Center marking
      translate([-BRIDGE_LENGTH/2,0,dy]) rotate([0,45,0]) cube([CENTER_MARKING_SIZE,BIG,CENTER_MARKING_SIZE],center=true);
    }
  }
}

*union() { // Ruler spacer
  RULER_WIDTH = 1*INCH;
  RULER_T = TEMPLATE_SZ;
  TRIANGLE_SIZE = RULER_WIDTH*2;
  cube([SX,RULER_WIDTH, RULER_T],center=true);
  cmirror([1,0,0]) translate([-SX/2,0,0]) {
    linear_extrude(height=RULER_T, center=true) triangle(TRIANGLE_SIZE, dir=[1,0]);
    translate([0,0,RULER_T/2]) {
      translate([0,-RULER_T*2/2,0]) cube(RULER_T*2);
      cmirror([0,1,0]) translate([0,RULER_WIDTH,0]) translate([0,-RULER_T/2,0]) cube(RULER_T);
    }
  }
}

*union() { // Cutting rig - like, uh, wrap cloth around it and cut all sheets at once
  BRACE_SZ = 20;
  BRACE_T = 5; //TODO We *might*, be able to reduce this, but these are all kinda load bearing....
  BRIDGE_SX = 20;
  SM_BRIDGE_SY = BRACE_T;
  BIG_BRIDGE_SY = SM_BRIDGE_SY*2;
  STOPPER_T = SM_BRIDGE_SY;
  BRIDGE_LENGTH = SX+0*INCH + STOPPER_T*2 + BRACE_SZ*2;
  CUTTING_GAP = 2;
  
  ADJUSTED_SPAN = SY-BIG_BRIDGE_SY/2-SM_BRIDGE_SY-CUTTING_GAP/2;

  translate([0,45,0]) cmirror([0,1,0]) translate([0,15,0])
  union() { // Edge brace
    linear_extrude(height=BRACE_SZ) {
      for (ps = [
          // Big bridge
          [[0,0],[0,BIG_BRIDGE_SY/2+BRACE_T/2]],
          [[0,BIG_BRIDGE_SY/2+BRACE_T/2],[BRIDGE_SX+BRACE_T,BIG_BRIDGE_SY/2+BRACE_T/2]],
          [[BRIDGE_SX+BRACE_T,BIG_BRIDGE_SY/2+BRACE_T/2],[BRIDGE_SX+BRACE_T,-BIG_BRIDGE_SY/2-BRACE_T/2]],
          [[BRIDGE_SX+BRACE_T,-BIG_BRIDGE_SY/2-BRACE_T/2],[0,-BIG_BRIDGE_SY/2-BRACE_T/2]],
          [[0,-BIG_BRIDGE_SY/2-BRACE_T/2],[0,0]],
      
          // Stem
          [[BRIDGE_SX+BRACE_T,0],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,0]],

          // Cutting bridges
          [[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,0],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,CUTTING_GAP/2+SM_BRIDGE_SY+BRACE_T/2]],
          [[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,CUTTING_GAP/2+SM_BRIDGE_SY+BRACE_T/2],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2+BRIDGE_SX+BRACE_T,CUTTING_GAP/2+SM_BRIDGE_SY+BRACE_T/2]],
          [[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2+BRIDGE_SX+BRACE_T,CUTTING_GAP/2+SM_BRIDGE_SY+BRACE_T/2],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2+BRIDGE_SX+BRACE_T,-CUTTING_GAP/2-SM_BRIDGE_SY-BRACE_T/2]],
          [[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2+BRIDGE_SX+BRACE_T,-CUTTING_GAP/2-SM_BRIDGE_SY-BRACE_T/2],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,-CUTTING_GAP/2-SM_BRIDGE_SY-BRACE_T/2]],
          [[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,-CUTTING_GAP/2-SM_BRIDGE_SY-BRACE_T/2],[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,0]],
        ]) {
        channel(from=ps[0],to=ps[1],d=BRACE_T,cap="square");
      }
      channel(from=[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2,0],to=[BRACE_T/2+ADJUSTED_SPAN-BRIDGE_SX-BRACE_T/2+BRIDGE_SX+BRACE_T,0],d=CUTTING_GAP,cap="none");
    }
  }
  //translate([BRACE_T/2,-20,0]) cube([ADJUSTED_SPAN,3,10]);
  //translate([BRACE_T/2,-15,0]) cube([BRIDGE_SX,3,10]);

  translate([BRIDGE_LENGTH,0,0]) translate([0,5,BIG_BRIDGE_SY/2]) rotate([90,0,0])
  union() { // Big bridge
    linear_extrude(height=BRIDGE_SX) { // Bridge
      channel(from=[0,0],to=[-BRIDGE_LENGTH,0],d=BIG_BRIDGE_SY,cap="triangle"); // I'd prefer "sharp", but that makes it juuust too long for my printer
    }
    translate([0,0,-BRACE_T]) linear_extrude(height=BRIDGE_SX+BRACE_T*2) { // Stopper
      channel(from=[-BRACE_SZ-STOPPER_T/2,-BIG_BRIDGE_SY/2],to=[-BRACE_SZ-STOPPER_T/2,BIG_BRIDGE_SY/2+BRACE_T],d=STOPPER_T,cap="none");
      channel(from=[-BRIDGE_LENGTH+BRACE_SZ+STOPPER_T/2,-BIG_BRIDGE_SY/2],to=[-BRIDGE_LENGTH+BRACE_SZ+STOPPER_T/2,BIG_BRIDGE_SY/2+BRACE_T],d=STOPPER_T,cap="none");
    }
  }
  //translate([-STOPPER_T-BRACE_SZ,-20,0]) mirror([1,0,0]) cube([10*INCH,3,10]);

  translate([BRIDGE_LENGTH,-50,0]) cmirror([0,1,0]) translate([0,-2.5,SM_BRIDGE_SY/2]) rotate([90,0,0])
  union() { // Cutting bridge - print 2
    linear_extrude(height=BRIDGE_SX) { // Bridge
      channel(from=[0,0],to=[-BRIDGE_LENGTH,0],d=SM_BRIDGE_SY,cap="triangle"); // I'd prefer "sharp", but that makes it juuust too long for my printer
    }
    linear_extrude(height=BRIDGE_SX+BRACE_T) { // Stopper
      channel(from=[-BRACE_SZ-STOPPER_T/2,-SM_BRIDGE_SY/2],to=[-BRACE_SZ-STOPPER_T/2,SM_BRIDGE_SY/2+BRACE_T],d=STOPPER_T,cap="none");
      channel(from=[-BRIDGE_LENGTH+BRACE_SZ+STOPPER_T/2,-SM_BRIDGE_SY/2],to=[-BRIDGE_LENGTH+BRACE_SZ+STOPPER_T/2,SM_BRIDGE_SY/2+BRACE_T],d=STOPPER_T,cap="none");
    }
  }
}

*union() { // Blade aligners
  // Note, these are a little hard to use, still.  You kinda need to keep the fabric tight, in
  // the direction of travel.  It may not be any easier than just cutting against the side of
  // the ruler or straightedge.  BUT it might still be useful for a corner you can't get an
  // easy angle right up against.
  BLADE_T = 1;
  BLADE_DEPTH = 2;
  WALL_ANGLE = 45; // Angle OUT of the plane of UPxCUTTING_DIRECTION
  
  union() { // X-Acto (tm or whatever)
    EDGE_ANGLE = 30; // Angle within the plane of the blade, vs the cut line.  At 0, imagine the xacto is straight up and down.
    BLADE_ANGLE = 22.19; // The (un)pointiness of the blade.  Rough value; did math on the blade I had handy
    B_SX = 50;
    B_SY = 10;
    B_SZ = 10;
    difference() {
      translate([-B_SX/4,-B_SY,0]) cube([B_SX,B_SY,B_SZ]); // Body
      
      // Notches
      translate([0,0,0]) cube([1,1,BIG],center=true);
      translate([0,0,B_SZ]) cube([1,BIG,1],center=true);
      translate([0,-B_SY,0]) cube([1,1,BIG],center=true);
      
      rotate([WALL_ANGLE,0,0]) translate([0,0,-BLADE_DEPTH]) rotate([0,EDGE_ANGLE,0]) rotate([90,0,0])
       difference() {
        rotate([0,0,90-BLADE_ANGLE]) translate([0,0,-BLADE_T/2]) cube([BIG,BIG,BLADE_T]);
        OXm();
      }
    }
  }
}