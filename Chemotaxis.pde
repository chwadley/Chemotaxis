import java.util.*;

double avg(double[] a) {
  return Arrays.stream(a).sum()/a.length;
}

double lerp(double a, double b, double t) {
  return a+(b-a)*t;
}

double dist(double x1, double y1, double x2, double y2) {
  double cx=x1-x2;
  /*if (x1<x2) {
    cx=Math.max(cx,x1+width-x2);
  }*/
  double cy=y1-y2;
  /*if (y1<y2) {
    cy=Math.max(cy,y1+height-y2);
  }*/
  return Math.sqrt(cx*cx+cy*cy);
}

class unit {
  float x,y;
  float dx,dy;
  ArrayList <Integer> neighbors=new ArrayList <Integer>(); //contains indexes of neighbor boids
  //int[] neighborArray;
  float rad;
  int id;
  float sf;
  float sd;
  float af;
  float ad;
  float cf;
  float cd;
  int r;
  int g;
  int b;
  unit(float _x, float _y, float _dx, float _dy, int _id, int _r, int _g, int _b) {
    x=_x;
    y=_y;
    dx=_dx;
    dy=_dy*2;
    id=_id;
    rad=50;
    r=_r;
    g=_g;
    b=_b;
    sf=0.05; //0.005 - separation factor
    sd=10; //20 - separation visual range
    af=0.03; //0.03 - alignment factor
    ad=25; //50 - alignment visual range
    cf=0.02; //0.005 - centering factor
    cd=37.5; //75 - centering visual range
  }
  void move() {
    x+=dx;
    y+=dy;
  }
  void bounce() {
    if (x<0) {
      dx=-dx;
      x=0;
    }
    if (x>width) {
      dx=-dx;
      x=width;
    }
    if (y<0) {
      dy=-dy;
      y=0;
    }
    if (y>height) {
      dy=-dy;
      y=height;
    }
  }
  void wrap() {
    //x%=width;
    //y%=height;
    if (x<0) {
      x=width;
    } else if (x>width) {
      x=0;
    }
    if (y<0) {
      y=height;
    } else if (y>height) {
      y=0;
    }
  }
  void slowBounce() {
    float bd=20; //bouncing distance
    float bf=1; //bouncing factor;
    if (x<bd) dx+=bf;
    if (x>width-bd) dx-=bf;
    if (y<bd) dy+=bf;
    if (y>height-bd) dy-=bf;
  }
  void show() {
    stroke(0);
    strokeWeight(2);
    noStroke();
    fill(r,g,b);
    ellipse(x,y,10,10);
  }
  void showVerbose() {
    noStroke();
    fill(255,128,0,64);
    ellipse(x,y,ad*2,ad*2);
    ellipse(x,y,sd*2,sd*2);
    ellipse(x,y,cd*2,cd*2);
    //fill(0);
    //text(Float.toString(dx)+" "+Float.toString(dy),x,y-20);
    show();
  }
  int[] getNeighbors(unit[] boids,float radius) {
    neighbors.clear();
    for (int i=0;i<boids.length;i++) {
      if (dist(x,y,boids[i].x,boids[i].y)<radius&&i!=id) {
        neighbors.add(i);
      }
    }
    int[] neighborArray=new int[neighbors.size()];
    for (int i=0;i<neighborArray.length;i++) {
      neighborArray[i]=neighbors.get(i);
    }
    return neighborArray;
  }
  void align(unit[] boids) {
    double dxs=0;
    double dys=0;
    int nn=0;
    for (unit boid:boids) {
      if (dist(boid.x,boid.y,x,y)<ad) {
        dxs+=boid.dx;
        nn++;
      }
    }
    dxs/=nn;
    dys/=nn;
    dx=lerp(dx,(float)dxs,af);
    dy=lerp(dy,(float)dys,af);
  }
  void separate(unit[] boids) {
    float sepx=0;
    float sepy=0;
    for (unit boid:boids) {
      if (dist(boid.x,boid.y,x,y)<sd) {
        sepx+=x-boid.x;
        sepy+=y-boid.y;
      }
    }
    dx+=sepx*sf;
    dy+=sepy*sf;
  }
  void cap() {
    double sp=Math.sqrt(dx*dx+dy*dy);
    if (sp>15&&sp!=0) {
      dx*=15.0/sp;
      dy*=15.0/sp;
    }
  }
  void center(unit[] boids) {
    float cx=0;
    float cy=0;
    float nn=0;
    for (unit boid:boids) {
      if (dist(x,y,boid.x,boid.y)<cd) {
        cx+=boid.x;
        cy+=boid.y;
        nn++;
      }
    }
    if (nn>0) {
      cx/=nn;
      cy/=nn;
      dx+=(cx-x)*cf;
      dy+=(cy-y)*cf;
    }
  }
  void goToMouse() {
    dx=x-mouseX;
    dy=y-mouseY;
    x=mouseX;
    y=mouseY;
  }
  void goToBoid(unit[] boids) {
    if (dist(boids[0].x,boids[0].y,x,y)<50) {
      x=lerp(x,boids[0].x,0.1);
      y=lerp(y,boids[0].y,0.1);
      dx-=(x-boids[0].x)*0.05;
      dy-=(y-boids[0].y)*0.05;
    }
  }
  void randomWalk() {
    float m=0.5;
    dx+=Math.random()*m-m/2;
    dy+=Math.random()*m-m/2;
  }
}

unit[] units=new unit[400];

void setup() {
  //System.out.println("start");
  size(1000,600);
  for (int i=0;i<units.length;i++) {
    units[i]=new unit((float)Math.random()*width,(float)Math.random()*height,(float)Math.random()*12-6,(float)Math.random()*12-6,i,(int)(Math.random()*255),(int)(Math.random()*255),(int)(Math.random()*255));
  }
}

void draw() {
  background(220);
  for (int i=1;i<units.length;i++) {
    units[i].align(units);
    units[i].separate(units);
    units[i].center(units);
    units[i].goToBoid(units);
    units[i].randomWalk();
    units[i].cap();
    units[i].slowBounce();
    units[i].move();
    units[i].show();
  }
  units[0].goToMouse();
  units[0].showVerbose();
  //System.out.println(units[0].r);
  stroke(0);
  fill(255);
  rect(45,60,270,45);
  fill(0);
  noStroke();
  //text(Integer.toString(c)+" out of "+Integer.toString(units.length)+" boids have disappeared, idk why",50,50);
  text("You are controlling "+units[0].getNeighbors(units,50).length+" boids.",50,75);
  text(round(frameRate)+" fps",50,100);
  //text(units[0].dx,25,100);
  //text(units[0].dy,50,100);
  //System.out.println(units[0].x);
  //text(Arrays.toString(units[0].getNeighbors(units,20)),50,150);
}
