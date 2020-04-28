use <deps.link/erhannisScad/misc.scad>
use <deps.link/scadFluidics/common.scad>

$fn=60;
EPS = 1e-10;
BIG = 1000;

INCH = 25.4;

CATCH_INTERVAL = 16;
CATCH_COUNT = 3; // Per side
CATCH_DEPTH = 8;
CATCH_OUT = 4;
CATCH_NUB_D = 4;

RX = 60; // Per half...kinda.  Mess with it until things are the right length.
//ANGLE_ZONE = 10; // Per half
ANGLE_ZONE = 5;
ANGLE = 0;
MIRROR_POINT = ([-cos(ANGLE),sin(ANGLE)]*ANGLE_ZONE);
WIDTH = 10;
THICK = 2.5;

BEND_WIDTH = WIDTH+CATCH_OUT+THICK;
//BEND_WIDTH = WIDTH;
BEND_TRANSITION = 5;

TALL_SZ = 2;
SHORT_SZ = 1;

cmirror(MIRROR_POINT) translate(-MIRROR_POINT) {
  // Frame
  linear_extrude(height=SHORT_SZ) difference() {
    union() { // Solid
      // Bend
      if (ANGLE == 0) {
        channel(from=[-ANGLE_ZONE,0],to=[ANGLE_ZONE,0],d=BEND_WIDTH);
      } else {
        channel($fn=1000,from=MIRROR_POINT,to=[ANGLE_ZONE,0],dir1=-MIRROR_POINT,dir2=[-1,0],d=BEND_WIDTH);
      }
      // Transition
      channel(from=[ANGLE_ZONE-EPS,0],to=[ANGLE_ZONE+BEND_TRANSITION+EPS,0],d1=BEND_WIDTH,d2=WIDTH);
      // Straight bit
      channel(from=[ANGLE_ZONE+BEND_TRANSITION-EPS,0],to=[RX,0],d=WIDTH);
    }
    union() { // Removed
      // Bend
      if (ANGLE == 0) {
        channel(from=[-ANGLE_ZONE,0],to=[ANGLE_ZONE,0],d=BEND_WIDTH-THICK*2);
      } else {
        channel($fn=1000,from=MIRROR_POINT,to=[ANGLE_ZONE,0],dir1=-MIRROR_POINT,dir2=[-1,0],d=BEND_WIDTH-THICK*2);
      }
      // Transition
      channel(from=[ANGLE_ZONE-EPS,0],to=[ANGLE_ZONE+BEND_TRANSITION+EPS,0],d1=BEND_WIDTH-THICK*2,d2=WIDTH-THICK*2);
      // Straight bit
      channel(from=[ANGLE_ZONE+BEND_TRANSITION-EPS,0],to=[RX,0],d=WIDTH-THICK*2);
    }
  }
  // Catches
  linear_extrude(height=TALL_SZ) {
    for (dx = [(RX-CATCH_INTERVAL*(CATCH_COUNT-1)):CATCH_INTERVAL:RX]) {
      translate([dx,0]) {
        cmirror([0,1]) for (ps = [
          [[0,0],[0,WIDTH/2+CATCH_OUT]],
          [[0,WIDTH/2+CATCH_OUT],[-CATCH_DEPTH,WIDTH/2+CATCH_OUT]]
        ]) {
          channel(from=ps[0],to=ps[1],d=THICK,cap="circle");
        }
        cmirror([0,1]) translate([-CATCH_DEPTH,WIDTH/2+CATCH_OUT-CATCH_NUB_D/2+THICK/2]) circle(d=CATCH_NUB_D);
      }
    }
  }
}