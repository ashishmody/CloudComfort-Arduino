// -*- mode:c -*-
/*
 * CloudComfort
 * (c) 2011
 */


#if defined(ARDUINO) && ARDUINO > 18
#include <SPI.h>
#endif

#include <Ethernet.h>
#include "AirConditioner.h"

byte mac[] = {0x90, 0xa2, 0xda, 0x00, 0x87, 0xde};
IPAddress ip(192, 168, 4, 91);

/* Talk to Heroku: */
char *herokuHostName = "cloudcomfort.heroku.com";
EthernetClient herokuClient;
AirConditioner airConditioner;

long lastConnectionTime = 0;        // last time you connected to the server, in milliseconds
boolean lastConnected = false;      // state of the connection last time through the main loop
const int postingInterval = 10000;  //delay between updates to Pachube.com

boolean static isIPValid = false;

int acStatus = -1;
int tempc = -1;
int fanSpeed = -1;
int ACTemp = -1;
    
void setup() {
  Serial.begin(9600);
  Serial.println("BOOT");

  delay(1000);
  // start the Ethernet connection:
  //Ethernet.begin(mac, ip);
    if (Ethernet.begin(mac) == 0) {
   // Configure manually:
   Serial.println("Configuring Manually");
   Ethernet.begin(mac, ip);
   } else {
   Serial.println("IP Found");
   }
   airConditioner.setupTemp();
   ACTemp = 19;
}

void loop() {
  // if there's no net connection, but there was one last time
  // through the loop, then stop the client:
  if (!herokuClient.connected() && lastConnected) {
    Serial.println();
    Serial.println("disconnecting.");
    herokuClient.stop();
  }
  // if you're not connected, and ten seconds have passed since
  // your last connection, then connect again and send data:
  if(!herokuClient.connected() && (millis() - lastConnectionTime > postingInterval)) {
    sendSensorValues();
  }
  // store the state of the connection for next time through
  // the loop:
  lastConnected = herokuClient.connected();
}


void sendSensorValues() {
  float temperature = getVoltage(0);  // getting the voltage reading from the temperature sensor
  int tempCelsius = (temperature - .5) * 100;          // converting from 10 mv per degree wit 500 mV offset
  // to degrees ((volatge - 500mV) times 100)
  Serial.print("T=");
  Serial.println(tempCelsius, DEC);
  sendData(tempCelsius);
}
/*
 * getVoltage() - returns the voltage on the analog input defined by
 * pin
 */
float getVoltage(int pin){
  return (analogRead(pin) * .004882814); //converting from a 0 to 1024 digital range
  // to 0 to 5 volts (each 1 reading equals ~ 5 millivolts
}



// this method makes a HTTP connection to the server:
void sendData(int thisData) {
  // if there's a successful connection:
  Serial.print("con2H:");
  if (herokuClient.connect(herokuHostName, 80)) {
    Serial.println("!");
    // send the HTTP PUT request. 

    herokuClient.print("POST /api/1/poll HTTP/1.1\n");
    herokuClient.print("Host: ");
    herokuClient.print(herokuHostName);
    herokuClient.print("\n");
    herokuClient.print("Content-Length: ");

    // calculate the length of the sensor reading in bytes:
    int thisLength = getLength(thisData) + 6;
    herokuClient.println(thisLength, DEC);

    // last pieces of the HTTP PUT request:
    herokuClient.print("Content-Type: application/x-www-form-urlencoded\n");
    herokuClient.println("Connection: close\n");

    // here's the actual content of the PUT request:
    herokuClient.print("tempc=");
    herokuClient.println(thisData, DEC);
    Serial.println("POST success.");

    while (!herokuClient.available()) {
    }
    int newAcStatus = -1;
    int newTempc = -1;
    int newFanSpeed = -1;
    while (herokuClient.available()) {
      String line = readLine();
      Serial.println(line);
      if (line.startsWith("ac=")) {
        int newAcStatus = line.substring(3).toInt();
      } 
      else if (line.startsWith("tempc=")) {
        newTempc = line.substring(6).toInt();
      } 
      else if (line.startsWith("fan=")) {
        newFanSpeed = line.substring(4).toInt();
      }
    }

    herokuClient.stop();

    // note the time that the connection was made:
    lastConnectionTime = millis();
    Serial.println("SUCCESS");

    if(acStatus != newAcStatus) {
      acStatus = newAcStatus;
      airConditioner.setPower(acStatus);      
    }
    if(ACTemp != newTempc) {
      ACTemp = newTempc;
      airConditioner.setThermostat(tempc);      
    }
    if(fanSpeed != newFanSpeed) {
      fanSpeed = newFanSpeed;
      airConditioner.setFanSpeed(fanSpeed);    
    }
  } 
  else {
    // if you couldn't make a connection:
    Serial.println("x");
  }
}

String readLine() {
  String line = "";
  line.reserve(40);
  char character;
  while((character = herokuClient.read()) != '\n') {
    if (character != '\r' && character != -1) {
      line += character;
    }
  }
  return line;
}

// This method calculates the number of digits in the
// sensor reading.  Since each digit of the ASCII decimal
// representation is a byte, the number of digits equals
// the number of bytes:

int getLength(int someValue) {
  // there's at least one byte:
  int digits = 1;
  // continually divide the value by ten, 
  // adding one to the digit count for each
  // time you divide, until you're at 0:
  int dividend = someValue /10;
  while (dividend > 0) {
    dividend = dividend /10;
    digits++;
  }
  // return the number of digits:
  return digits;
}


