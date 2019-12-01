import processing.serial.*;

// arduino stuff
Serial myPort;
String values; //to hold potentiometer values
float wt1 = 0;
float wt2 = 0;
float wt3 = 0;

// network stuff
ArrayList<Node> vertices = new ArrayList();
ArrayList<Link> links = new ArrayList();
ArrayList<Node> openSet = new ArrayList();
ArrayList<Node> closedSet = new ArrayList();
ArrayList<Node> path = new ArrayList();


Node doverbloor = new Node("Dovercourt/Bloor", 200, 100);
Node ozbloor = new Node("Ossington/Bloor", 300, 100);
Node ozcollege = new Node("Ossington/College", 300, 300);
Node dovercollege =  new Node("Dovercourt/College", 200, 300);
Node duffcollege =  new Node("Dufferin/College", 50, 300);

Node start;
Node end;

// set up heuristic function for astar
float heuristic(Node a, Node b) {
  float d = dist(a.px, a.py, b.px, b.py);
  return d;
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
  vertices.add(doverbloor);
  vertices.add(ozbloor);
  vertices.add(ozcollege);
  vertices.add(dovercollege);
  vertices.add(duffcollege);

  //add neighbors
  ozcollege.addNeighbor(ozbloor);
  ozcollege.addNeighbor(dovercollege);

  ozbloor.addNeighbor(doverbloor);
  ozbloor.addNeighbor(ozcollege);

  doverbloor.addNeighbor(ozbloor);
  doverbloor.addNeighbor(dovercollege);

  dovercollege.addNeighbor(doverbloor);
  dovercollege.addNeighbor(duffcollege);
  dovercollege.addNeighbor(ozcollege);

  duffcollege.addNeighbor(dovercollege);

  // ----------------------

  // init links (the actual lines)
  //street links
  links.add( new Link("Bloor", "Dovercourt/Bloor", "Ossington/Bloor"));
  links.add( new Link("Ossington", "Ossington/Bloor", "Ossington/College"));
  links.add( new Link("College", "Dufferin/College", "Dovercourt/College"));
  links.add( new Link("College", "Dovercourt/College", "Ossington/College"));
  links.add( new Link("Dovercourt", "Dovercourt/Bloor", "Dovercourt/College"));

  start = ozcollege;
  end = duffcollege;

  openSet.add(start);
}

void draw() {
  background(255);
  for (int i=0; i<links.size (); i++) {
    links.get(i).draw();
    //println(links.get(i).from);
  }
  for (int i=0; i<vertices.size (); i++) {
    vertices.get(i).draw();
  }

  //Get arduino values
  if (myPort.available() > 0) {
    values = myPort.readStringUntil('\n');
  }

  if (values != null) {
    println(values);
    values = trim(values);
    
    float[] weights = float(split(values, ","));
    if (weights.length == 3) {
      wt1 = map(weights[0], 0, 1023, 0, 100);
      wt2 = map(weights[1], 0, 1023, 0, 100);
      wt3 = map(weights[2], 0, 1023, 0, 100);
    }
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
        println(neighbor.name);
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
    for (int i=0; i<vertices.size (); i++) {
      if (vertices.get(i).name.equals(from)) {
        px1 = vertices.get(i).px;
        py1 = vertices.get(i).py;
      }
      if (vertices.get(i).name.equals(to)) {
        px2 = vertices.get(i).px;
        py2 = vertices.get(i).py;
      }
    } // for
    stroke(0);
    line(px1, py1, px2, py2);

    fill(0);
    textAlign(CENTER, CENTER);
    text(name, ((px1+px2)/2)-25, ((py1+py2)/2)-12);
  } // method
} // class 
//
