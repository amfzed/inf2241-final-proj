import processing.serial.*;

// arduino stuff
boolean arduino = false;
Serial myPort;
String values; //to hold potentiometer values
float wt1 = 0;
float wt2 = 0;
float wt3 = 0;

// network stuff
ArrayList<Node> nodes = new ArrayList();
ArrayList<Link> links = new ArrayList();
ArrayList<Node> openSet = new ArrayList();
ArrayList<Node> closedSet = new ArrayList();
ArrayList<Node> path = new ArrayList();


Node doverbloor = new Node("Dovercourt/Bloor", 200, 100);
Node doverhep = new Node("Dovercourt/Hepbourne", 200, 130);
Node ozbloor = new Node("Ossington/Bloor", 300, 100);
Node ozhep = new Node("Ossington/Hepbourne", 300, 170);
Node ozcollege = new Node("Ossington/College", 300, 300);
Node dovercollege =  new Node("Dovercourt/College", 200, 300);
Node duffcollege =  new Node("Dufferin/College", 50, 300);

Node start;
Node end;

// set up heuristic function for astar
float heuristic(Node a, Node b) {
  float d = dist(a.px, a.py, b.px, b.py);
  if (arduino == true) {
    println("Arduino detected");
  }
  return d;
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
  size(1200, 600);

  // init arduino listener, if one is connected
  if (Serial.list().length > 0) {
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 115200);
  }


  // init nodes 
  // street nodes
  nodes.add(doverbloor);
  nodes.add(doverhep);
  nodes.add(ozbloor);
  nodes.add(ozhep);
  nodes.add(ozcollege);
  nodes.add(dovercollege);
  nodes.add(duffcollege);

  //add neighbors
  linkNodes(ozcollege, dovercollege);
  linkNodes(ozcollege, ozhep);

  linkNodes(ozbloor, doverbloor);
  linkNodes(ozbloor, ozhep);
  linkNodes(ozhep, doverhep);
  linkNodes(doverbloor, doverhep);
  linkNodes(doverhep, dovercollege);

  linkNodes(duffcollege, dovercollege);

  // ----------------------


  start = doverbloor;
  end = ozcollege;

  openSet.add(start);
}

void serialEvent(Serial myPort) {
  //Get arduino values
  if (myPort.available() > 0) {
    values = myPort.readStringUntil('\n');
    arduino = true;
  }

  if (arduino == true && values != null) {
    //println(values);
    values = trim(values);

    float[] weights = float(split(values, ","));
    if (weights.length == 3) {
      wt1 = map(weights[0], 0, 1023, 0, 100);
      wt2 = map(weights[1], 0, 1023, 0, 100);
      wt3 = map(weights[2], 0, 1023, 0, 100);
    }
  }
}

void draw() {
  background(255);

  //draw links and nodes
  for (Link l : links) {
    l.draw();
  }
  for (Node n : nodes) {
    n.draw();
  }

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
      print(path);
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


// =============================================

class Node {

  String name;
  float px, py;
  color c;
  ArrayList<Node> neighbors;
  Node parent;

  float heuristic = 0;
  float g = 0;

  // constr
  Node(String name_, 
    float px_, float py_) {
    px=px_;
    py=py_;
    name=name_;
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
      start = this;
    }
  } // method

  void addNeighbor(Node n) {
    this.neighbors.add(n);
  }

  float f() {
    return heuristic + g;
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
    stroke(0);
    line(px1, py1, px2, py2);

    fill(0);
    textAlign(CENTER, CENTER);
    text(name, ((px1+px2)/2)-25, ((py1+py2)/2)-12);
  } // method

  void mousePressed() {
    println("HI");
  }
} // class 
//
