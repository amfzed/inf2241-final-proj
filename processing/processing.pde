import processing.serial.*;

// arduino stuff
boolean arduino;
Serial myPort;
String values; //to hold potentiometer values
float wt1;
float wt2;
float wt3;

// map stuff
PImage bg;

// network stuff
ArrayList<Node> nodes = new ArrayList();
ArrayList<Link> links = new ArrayList();
ArrayList<Node> openSet = new ArrayList();
ArrayList<Node> closedSet = new ArrayList();
ArrayList<Node> path = new ArrayList();

// nodes
Node bwaystate; //"Broadway/State", 531, 428
Node bwayfork; //"Broadway/Broadway", 608, 297
Node bwaymorris;
Node bwayxchange; // "Broadway/Exchange", 687, 157
Node bwaywall; //"Broadway/Wall", 761, 43
Node bwaybeaver; //"Broadway/Beaver", 615, 374
Node bwaystone; //"Broadway/Stone", 625, 496
Node stonebroad; //"Stone/Broad", 776, 497
Node broadswilliam; //"Broad/S.William", 781, 469
Node beavernewmktfield; //"Beaver/New/Marketfield", 680, 374
Node beaverbroad; //"Beaver/Broad", 779, 377
Node newxchange; //"New/Exchange", 747, 187
Node broadxchange; //"Broad/Exchange", 812, 221
Node newwall; 
Node mktbroad;
Node mktdogleg;
Node wallbroad;
Node swilliamalley;
Node swilliammill;
Node beaverswilliam;
Node williamxchange;
Node wallwilliam;
Node wallhanover;
Node xchangehanover;
Node statebridge;
Node statepearl;
Node bwaybridge;
Node whitehallpearl;
Node wallpearl;
Node beaverhanover;
Node hanoverpearl;
Node williampearl;
Node williamstone;
Node pearlcoenties;
Node stonecoenties;
Node broadpearl;
Node millstone;

// start and endpoints
Node start;
Node end;

// set up heuristic function for astar
float heuristic(Node a, Node b) {
  float d = dist(a.px, a.py, b.px, b.py);
  float valAvg = (a.val + b.val)/2;
  float randAvg = (a.rand + b.rand)/2;
  if (arduino == true) {
    println("Arduino detected");
    d = (d * wt1);
    valAvg = (valAvg * wt2);
    randAvg = randAvg * wt3;
  }
  return d + valAvg + randAvg;
}

void linkNodes(Node a, Node b) {
  //create bidirectional link between specified nodes
  a.addNeighbor(b);
  b.addNeighbor(a);

  //figure out the street name and add the link for display
  String streetName = "";
  StringList aStreets = new StringList(split(a.name, "/"));
  StringList bStreets = new StringList(split(b.name, "/"));

  for (String i : aStreets) {
    if (bStreets.hasValue(i)) {
      streetName = i;
    }
  }
  links.add(new Link(streetName, a.name, b.name));
}

void setup() {
  size(1200, 1000);
  frameRate(10);
  bg = loadImage("basemap.png");

  arduino = false;
  // init arduino listener, if one is connected
  if (Serial.list().length > 0) {
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 115200);
  }

  // starting weights
  wt1 = 1;
  wt2 = 1;
  wt3 = 1;

  // init nodes 
  Node bwaystate = new Node("Broadway/State", 531, 428);
  Node bwayfork = new Node("Broadway/Broadway", 608, 297);
  Node bwaymorris = new Node("Broadway/Morris", 617, 273);
  Node bwayxchange = new Node("Broadway/Exchange", 687, 157);
  Node bwaywall = new Node("Broadway/Wall", 761, 43);
  Node bwaybeaver = new Node("Broadway/Beaver", 615, 374);
  Node bwaystone = new Node("Broadway/Stone", 625, 496);
  Node stonebroad = new Node("Stone/Broad", 776, 497);
  Node broadswilliam = new Node("Broad/S.William", 776, 469);
  Node beavernewmktfield = new Node("Beaver/New", 680, 374);
  Node beaverbroad = new Node("Beaver/Broad", 779, 377);
  Node newxchange = new Node("New/Exchange", 747, 187);
  Node broadxchange = new Node("Broad/Exchange", 812, 221);
  Node newwall = new Node("New/Wall", 807, 70);
  Node mktbroad = new Node("Marketfield/Broad", 775, 415);
  Node mktdogleg = new Node("Marketfield/MarketField", 685, 416);
  Node wallbroad = new Node("Broad/Wall", 858, 113);
  Node swilliamalley = new Node("S.William/Coenties", 840, 445);
  Node swilliammill = new Node("S.William/Mill", 895, 409);
  Node beaverswilliam = new Node("Beaver/S.William", 923, 356);
  Node williamxchange = new Node("William/Exchange", 935, 280);
  Node wallwilliam = new Node("William/Wall", 968, 208);
  Node wallhanover = new Node("Hanover/Wall", 1034, 256);
  Node xchangehanover = new Node("Hanover/Exchange", 1011, 309);
  Node statebridge = new Node("State/Bridge", 514, 547);
  Node statepearl = new Node("State/Pearl", 507, 604);
  Node bwaybridge = new Node("Broadway/Bridge", 632, 553);
  Node whitehallpearl = new Node("Whitehall/Pearl", 642, 605);
  Node wallpearl = new Node("Wall/Pearl", 1115, 312);
  Node beaverhanover = new Node("Beaver/Hanover", 1012, 342);
  Node hanoverpearl = new Node("Hanover/Pearl", 1023, 395);
  Node williampearl = new Node("William/Pearl", 970, 434);
  Node williamstone = new Node("William/Stone", 948, 408);
  Node pearlcoenties = new Node("Pearl/Coenties", 862, 538);
  Node stonecoenties = new Node("Stone/Coenties", 857, 484);
  Node broadpearl = new Node("Broad/Pearl", 773, 564);
  Node millstone = new Node("Mill/Stone", 915, 431);

  // street nodes
  nodes.add(bwaystate);
  nodes.add(bwayfork);
  nodes.add(bwaymorris);
  nodes.add(bwayxchange);
  nodes.add(bwaywall);
  nodes.add(bwaybeaver);
  nodes.add(bwaystone);
  nodes.add(stonebroad);
  nodes.add(broadswilliam);
  nodes.add(beavernewmktfield);
  nodes.add(beaverbroad);
  nodes.add(newxchange);
  nodes.add(broadxchange);
  nodes.add(newwall);
  nodes.add(mktbroad);
  nodes.add(mktdogleg);
  nodes.add(wallbroad);
  nodes.add(swilliamalley);
  nodes.add(swilliammill);
  nodes.add(beaverswilliam);
  nodes.add(williamxchange);
  nodes.add(wallwilliam);
  nodes.add(wallhanover);
  nodes.add(xchangehanover);
  nodes.add(statebridge);
  nodes.add(statepearl);
  nodes.add(bwaybridge);
  nodes.add(whitehallpearl);
  nodes.add(wallpearl);
  nodes.add(beaverhanover);
  nodes.add(hanoverpearl);
  nodes.add(williampearl);
  nodes.add(williamstone);
  nodes.add(pearlcoenties);
  nodes.add(stonecoenties);
  nodes.add(broadpearl);
  nodes.add(millstone);

  //add neighbors
  linkNodes(bwaystate, bwayfork);
  linkNodes(bwayfork, bwaymorris);
  linkNodes(bwaymorris, bwayxchange);
  linkNodes(bwayxchange, bwaywall);
  linkNodes(bwayfork, bwaybeaver);
  linkNodes(bwaybeaver, beavernewmktfield);
  linkNodes(beavernewmktfield, beaverbroad);
  linkNodes(beavernewmktfield, newxchange);
  linkNodes(beavernewmktfield, mktdogleg);
  linkNodes(newxchange, broadxchange);
  linkNodes(newxchange, bwayxchange);
  linkNodes(broadxchange, beaverbroad);
  linkNodes(beaverbroad, mktbroad);
  linkNodes(beaverbroad, beaverswilliam);
  linkNodes(mktbroad, mktdogleg);
  linkNodes(mktbroad, broadswilliam);
  linkNodes(broadswilliam, swilliamalley);
  linkNodes(broadswilliam, stonebroad);
  linkNodes(newxchange, newwall);
  linkNodes(newwall, bwaywall);
  linkNodes(bwaystone, bwaybeaver);
  linkNodes(bwaystone, stonebroad);
  linkNodes(newwall, wallbroad);
  linkNodes(wallbroad, broadxchange);
  linkNodes(swilliamalley, swilliammill);
  linkNodes(swilliammill, beaverswilliam);
  linkNodes(bwaystate, statebridge);
  linkNodes(statebridge, statepearl);
  linkNodes(bwaystate, bwaybeaver);
  linkNodes(bwaystone, bwaybridge);
  linkNodes(bwaybridge, whitehallpearl);
  linkNodes(statebridge, bwaybridge);
  linkNodes(statepearl, whitehallpearl);
  linkNodes(broadxchange, williamxchange);
  linkNodes(beaverswilliam, williamxchange);
  linkNodes(williamxchange, wallwilliam);
  linkNodes(wallwilliam, wallbroad);
  linkNodes(wallwilliam, wallhanover);
  linkNodes(xchangehanover, wallhanover);
  linkNodes(williamxchange, xchangehanover);
  linkNodes(wallhanover, wallpearl);
  linkNodes(xchangehanover, beaverhanover);
  linkNodes(beaverswilliam, beaverhanover);
  linkNodes(beaverhanover, wallpearl);
  linkNodes(hanoverpearl, wallpearl);
  linkNodes(williamstone, beaverswilliam);
  linkNodes(williamstone, williampearl);
  linkNodes(williamstone, hanoverpearl);
  linkNodes(williampearl, hanoverpearl);
  linkNodes(beaverhanover, hanoverpearl);
  linkNodes(williampearl, pearlcoenties);
  linkNodes(swilliamalley, stonecoenties);
  linkNodes(stonecoenties, pearlcoenties);
  linkNodes(pearlcoenties, broadpearl);
  linkNodes(broadpearl, whitehallpearl);
  linkNodes(broadpearl, bwaybridge);
  linkNodes(stonebroad, broadpearl);
  linkNodes(swilliammill, millstone);
  linkNodes(millstone, williamstone);
  linkNodes(millstone, stonecoenties);
  

  start = bwayfork;
  end = wallpearl;

  openSet.add(start);
}

void serialEvent(Serial myPort) {
  //Get arduino values
  if (myPort.available() > 0) {
    values = myPort.readStringUntil('\n');
    arduino = true;
  }

  if (arduino == true && values != null) {
    println(values);
    values = trim(values);

    float[] weights = float(split(values, ","));
    if (weights.length == 3) {
      if (weights[0] <= 100  || Float.isNaN(weights[0])) {
        wt1 = 0;
      } else {
        wt1 = map(weights[0], 0, 1023, 0, 10);
      }

      if (weights[1] <= 100  || Float.isNaN(weights[1])) {
        wt2 = 0;
      } else {
        wt2 = map(weights[1], 0, 1023, 0, 10);
      }

      if (weights[2] <= 100  || Float.isNaN(weights[2])) {
        wt3 = 0;
      } else {
        wt3 = map(weights[2], 0, 1023, 0, 10);
      }
    }
  }
}

void draw() {
  delay(1000);
  background(bg);
  //draw links and nodes
  for (Link l : links) {
    l.draw();
  }
  for (Node n : nodes) {
    n.draw();
  }

  // display the weights
  textSize(18);
  fill(50);
  text(int(wt1), 50, 80);
  text(int(wt2), 50, 120);
  text(int(wt3), 50, 160);

  //the astar magic
  if (openSet.size() == 0) {
    noLoop();
  } else {
    Node current = openSet.get(0);
    for (Node v : openSet) {
      if (v.f() < current.f()) current = v;
    }

    // finish this up if you're at the endpoint
    if (current == end) {
      // if you've made it to the end, clear out all your sets
      openSet.clear();
      closedSet.clear();
      path.clear();
      //...and start building the path out of the way you came
      Node origin = current;
      path.add(origin);
      while (origin.parent != null) {
        path.add(origin.parent);
        origin = origin.parent;
      }
      println(" All done");
    } else {
      // if you're not done yet
      openSet.remove(current);
      closedSet.add(current);

      for (Node neighbor : current.neighbors) {
        if (!closedSet.contains(neighbor)) {
          // MODIFY THIS FOR THE PROJECT
          float tempG = current.g + heuristic(neighbor, current);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
            neighbor.g = tempG;
            neighbor.heuristic = heuristic(neighbor, end);
            neighbor.parent = current;
          } else {
            if (tempG < neighbor.g) {
              neighbor.g = tempG;
              neighbor.parent = current;
              neighbor.heuristic = heuristic(neighbor, end);
            } // end if cost is less than neighbor's cost block
          } // end else block
          println(current.g);
        } //end block if the closedSet doesn't contain neighbor
      } //end for neighbor in list of neighbors
    } // end else not-done-yet block

    path.clear();
    Node origin = current;
    path.add(origin);
    while (origin.parent != null) {
      path.add(origin.parent);
      origin = origin.parent;
    } // end while origin.parent != null block
  } // end non-empty open set block

  // draw path
  stroke(0, 0, 255);
  strokeWeight(4);
  noFill();
  beginShape();
  for (Node n : path) {
    vertex(n.px, n.py);
  }
  endShape();
  strokeWeight(1); // draw everything not chosen lightly
  arduino = false;
}

void reset() {
  arduino = false;
  openSet.clear();
  closedSet.clear();
  path.clear();

  wt1 = 1;
  wt2 = 1;
  wt3 = 1;

  for (Node n : nodes) {
    n.resetVars();
    //n.rerollVal();
  }

  // start = nodes.get(int(random(nodes.size())));
  println(start.name);
  openSet.add(start);
}

void mouseClicked() {
  //on mouseclick, rerun
  reset();
  println("clicked!");
  loop();
}

// =============================================

class Node {

  String name;
  float px, py, val, rand;
  color c;
  ArrayList<Node> neighbors;
  Node parent;
  int maxVal = 400;
  int maxRand = 400;

  float heuristic = 0;
  float g = 0;

  // constructor 1
  Node(String name_, 
    float px_, float py_) {
    px=px_;
    py=py_;
    name=name_;
    val = random(0, maxVal);
    rand = random(0, maxRand);
    c=color(random(255), random(255), random(255));
    this.neighbors = new ArrayList<Node>();
  } // constr

  // constructor -- extra val specified
  Node(String name_, 
    float px_, float py_, float val_) {
    px=px_;
    py=py_;
    name=name_;
    val = val_;
    rand = random(0, maxRand);
    c=color(random(255), random(255), random(255));
    this.neighbors = new ArrayList<Node>();
  } // constr

  // constructor -- val and rand specified
  Node(String name_, 
    float px_, float py_, float val_, float rand_) {
    px=px_;
    py=py_;
    name=name_;
    val = val_;
    rand = rand_;
    rand = random(0, maxRand);
    c=color(random(255), random(255), random(255));
    this.neighbors = new ArrayList<Node>();
  } // constr

  void draw() {
    // show a circle 
    fill(c);
    stroke(0);
    ellipse(px, py, 15, 15);

    // show the name of the node 
    //fill(0);
    //textAlign(CENTER, CENTER);
    //text(name, px-22, py-22);

    // the mouse over effect 
    if (dist(mouseX, mouseY, px, py)<=10) {
      // show the name of the node 
      fill(0);
      textAlign(CENTER, CENTER);
      text(name, px, py-22);
    }
  } // method

  Node listen() {
    //nothing for now
    if (dist(mouseX, mouseY, px, py)<=10) {
      // show the name of the node 
      println(name);
      return this;
    }
    return null;
  }

  void addNeighbor(Node n) {
    this.neighbors.add(n);
  }

  void rerollVal() {
    val = random(0, maxVal);
  }

  void resetVars() {
    g = 0;
    heuristic = 0;
    parent = null;
  }

  float f() {
    return heuristic + g + val;
  }
} // class

// ==========================================

class Link {
  String name;
  String from;
  String to;

  // constr
  Link(String _name, String _from, String _to) {
    name=_name;
    from=_from;
    to=_to;
  } // constr

  void draw() {
    // show the lines 
    float px1=-1, py1=-1, px2=-1, py2=-1;
    for (int i=0; i<nodes.size (); i++) {
      if (nodes.get(i).name.equals(from)) {
        px1 = nodes.get(i).px;
        py1 = nodes.get(i).py;
      }
      if (nodes.get(i).name.equals(to)) {
        px2 = nodes.get(i).px;
        py2 = nodes.get(i).py;
      }
    } // for
    stroke(3);
    line(px1, py1, px2, py2);

    //fill(0);
    //textAlign(CENTER, CENTER);
    //text(name, ((px1+px2)/2)-25, ((py1+py2)/2)-12);
  } // draw method
} // class 
