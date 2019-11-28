import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*; 
import de.fhpotsdam.unfolding.providers.AbstractMapProvider;
import de.fhpotsdam.unfolding.providers.Microsoft;

import processing.serial.*;

// map setup
UnfoldingMap map;
AbstractMapProvider p1;
AbstractMapProvider p2;

// Serial listener setup
Serial myPort;  // Create object from Serial class
String val = "0"; // Data received from the serial port

float redValue = 0;        // red value

int[][] costDist = {  {10, 1, 2, 3}, 
  {3, 2, 1, 10}, 
  {3, 5, 6, 1}, 
  {3, 8, 3, 4}  };

int[][] costX = {  {1000, 5000, 1000, 3000}, 
  {4000, 6000, 1000, 0}, 
  {5000, 0, 900, 0}, 
  {1250, 8000, 2000, 2000}  };

int startNode = 0;
int endNode = 1;


void setup()
{
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 115200);
  size(1000, 800);

  // map setup
  p1 = new Microsoft.AerialProvider();
  p2 = new Microsoft.RoadProvider();
  map = new UnfoldingMap(this, p2);
  MapUtils.createDefaultEventDispatcher(this);
  map.zoomAndPanTo(new Location(43.664414, -79.4000), 18);
}

void draw()
{
  map.draw();
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n');   // read it and store it in val
  }

  if (val != null) {
    // if there is a value, do all this
    float color_val = float(val);
    redValue = map(color_val, 0, 1023, 0, 255);
    println(color_val); //print it out in the console
    float costA = costDist[startNode][endNode] * redValue;
    println(costA);
    float costB = costX[startNode][endNode] * (2 / redValue);
    println(costB);
    float lowest;
    if (costA < costB) {
      lowest = costA;
      println("costA is lower");
      if (map.mapDisplay.getMapProvider() == p2)
      {      
        map.mapDisplay.setProvider(p1);
      }
    } else {
      lowest = costB;
      println("costB is lower");
      if (map.mapDisplay.getMapProvider() == p1) {
        map.mapDisplay.setProvider(p2);
      }
    }
  }
}
