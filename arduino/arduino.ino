/* Analog Read to LED
   ------------------

   turns on and off a light emitting diode(LED) connected to digital
   pin 13. The amount of time the LED will be on and off depends on
   the value obtained by analogRead(). In the easiest case we connect
   a potentiometer to analog pin 2.

   Created 1 December 2005
   copyleft 2005 DojoDave <http://www.0j0.org>
   http://arduino.berlios.de

  processing tutorial: https://learn.sparkfun.com/tutorials/connecting-arduino-to-processing/all

*/

int pot1Pin = 0;    // select the input pin for the potentiometer
int pot2Pin = 1;
int pot3Pin = 2;
int ledPin = 13;   // select the pin for the LED
int val1 = 0;       // variable to store the value coming from the sensor
int val2 = 0;
int val3 = 0;

void setup() {
  pinMode(ledPin, OUTPUT);  // declare the ledPin as an OUTPUT
  Serial.begin(115200); 
}

void loop() {
  val1 = analogRead(pot1Pin);    // read the value from the sensor
  delay(15);
  val2 = analogRead(pot2Pin);
  delay(15);
  val3 = analogRead(pot3Pin);
  delay(15);
  Serial.print(val1);
  Serial.print(",");
  Serial.print(val2);
  Serial.print(",");
  Serial.print(val3);
  Serial.print("\n");
}
