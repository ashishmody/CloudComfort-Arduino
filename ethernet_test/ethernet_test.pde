// -*- mode:c -*-
/*
 * CloudComfort
 * (c) 2011
 */

#define STATIC_IP 1
#define DHCP 0

#include <HashMap.h>
#include <PusherClient.h>

#if DHCP
#include <EthernetDHCP.h>
#endif /* DHCP */

#if defined(ARDUINO) && ARDUINO > 18
#include <SPI.h>
#endif

#include <Ethernet.h>

byte ip[] = {192, 168, 4, 99};
byte mac[] = {0x90, 0xa2, 0xda, 0x00, 0x87, 0xde};
byte gateway[] = { 192, 168, 4, 1 }; //MY DSL DEVICE
byte subnet[] = { 255, 255, 255, 0 }; //MY SUBNET MASK
const char* ip_to_str(const uint8_t*);
boolean static didPusherClientConnect = false;
PusherClient pusherClient("PUSHER_API_KEY_HERE");

/* Talk to Heroku: */
byte herokuServer[] = { 107, 22, 233, 248 }; 
const char* herokuHostName = "HEROKU_HOSTNAME_HERE";
Client herokuClient(herokuServer, 80);


long lastConnectionTime = 0;        // last time you connected to the server, in milliseconds
boolean lastConnected = false;      // state of the connection last time through the main loop
const int postingInterval = 10000;  //delay between updates to Pachube.com

boolean static isIPValid = false;

void setup() {
  Serial.begin(9600);
  Serial.println("BOOT");

#ifdef STATIC_IP
  Ethernet.begin(mac, ip);
  Serial.print("Static IP: ");
  Serial.println(ip_to_str(ip));
  delay(1000);
  isIPValid = true;
#else /* STATIC_IP */

#ifdef POLLING_DHCP
  EthernetDHCP.begin(mac,1);
#else
  synchronousDHCP();
  isIPValid = true;
#endif /* POLLING_DHCP */
#endif /* STATIC_IP */
  

   //boolean firstTime = true;
   //getAnIp();
   //if (firstTime) {
   //firstTime = false;
   
   //}*/
  
}

void loop() {

#if DHCP && !POLLING_DHCP
  /* keep our DHCP lease active */
  EthernetDHCP.maintain();
#endif

  if (!isIPValid) {
#if DHCP && POLLING_DHCP
    Serial.println("getAnIP");
    getAnIP();
#endif
  } else {
    if (!didPusherClientConnect) {
      Serial.print("Starting PusherClient Connection: ");
      if (pusherClient.connect()) {
        Serial.println("connected");
        pusherClient.bindAll(ac);
        pusherClient.subscribe("cloudcomfort");
        didPusherClientConnect = true;
	Serial.println("connected");
      } else {
	Serial.println("failed");
        // if you didn't get a connection to the server:
        didPusherClientConnect = false;
	Serial.println("didn't connect.");
      }
    } else {
      // if there are incoming bytes available 
      // from the server, read them and print them:
      if (pusherClient.connected()) {
	pusherClient.monitor();
      } else {
	didPusherClientConnect = false;
	//	Serial.println("in loop! not connected"); 
      }
      sendSensorValues();
    }
  }
}

void sendSensorValues() {
  float temperature = getVoltage(0);  // getting the voltage reading from the temperature sensor
  int tempCelsius = (temperature - .5) * 100;          // converting from 10 mv per degree wit 500 mV offset
                                                   // to degrees ((volatge - 500mV) times 100)
  Serial.print("Reporting temperature: ");
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

// Just a utility function to nicely format an IP address.
const char* ip_to_str(const uint8_t* ipAddr) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}

void ac(String data) {  
  Serial.print("AC Event: ");
  Serial.println(data);
}

#if DHCP && POLLING_DHCP
void pollingDHCP() {

  
  static DhcpState prevState = DhcpStateNone;
  static unsigned long prevTime = 0;
  while(1) {    
    // poll() queries the DHCP library for its current state (all possible values
    // are shown in the switch statement below). This way, you can find out if a
    // lease has been obtained or is in the process of being renewed, without
    // blocking your sketch. Therefore, you could display an error message or
    // something if a lease cannot be obtained within reasonable time.
    // Also, poll() will actually run the DHCP module, just like maintain(), so
    // you should call either of these two methods at least once within your
    // loop() section, or you risk losing your DHCP lease when it expires!
    DhcpState state = EthernetDHCP.poll();

    if (prevState != state) {
      Serial.println();
      
      switch (state) {
      case DhcpStateDiscovering:
        Serial.print("Discovering servers.");
        break;
      case DhcpStateRequesting:
        Serial.print("Requesting lease.");
        break;
      case DhcpStateRenewing:
        Serial.print("Renewing lease.");
        break;
      case DhcpStateLeased: {
        Serial.println("Obtained lease!");

        // Since we're here, it means that we now have a DHCP lease, so we
        // print out some information.
        const byte* ipAddr = EthernetDHCP.ipAddress();
        const byte* gatewayAddr = EthernetDHCP.gatewayIpAddress();
        const byte* dnsAddr = EthernetDHCP.dnsIpAddress();

        Serial.print("My IP address is ");
        Serial.println(ip_to_str(ipAddr));

        Serial.print("Gateway IP address is ");
        Serial.println(ip_to_str(gatewayAddr));

        Serial.print("DNS IP address is ");
        Serial.println(ip_to_str(dnsAddr));
	isIPValid = true;
        Serial.println();
        break;
      }
      }
    } else if (state != DhcpStateLeased && millis() - prevTime > 300) {
      prevTime = millis();
      Serial.print('.'); 
    } else {
      Serial.print('x');
    }
    
    prevState = state; 
    if (isIPValid)
      break;
  }
}
#endif /* POLLING_DHCP */

#if DHCP && !POLLING_DHCP
void synchronousDHCP() {
  Serial.println("Attempting to obtain a DHCP lease...");
  
  // Initiate a DHCP session. The argument is the MAC (hardware) address that
  // you want your Ethernet shield to use. This call will block until a DHCP
  // lease has been obtained. The request will be periodically resent until
  // a lease is granted, but if there is no DHCP server on the network or if
  // the server fails to respond, this call will block forever.
  // Thus, you can alternatively use polling mode to check whether a DHCP
  // lease has been obtained, so that you can react if the server does not
  // respond (see the PollingDHCP example).
  EthernetDHCP.begin(mac);

  // Since we're here, it means that we now have a DHCP lease, so we print
  // out some information.
  const byte* ipAddr = EthernetDHCP.ipAddress();
  const byte* gatewayAddr = EthernetDHCP.gatewayIpAddress();
  const byte* dnsAddr = EthernetDHCP.dnsIpAddress();
  
  Serial.println("A DHCP lease has been obtained.");

  Serial.print("My IP address is ");
  Serial.println(ip_to_str(ipAddr));
  
  Serial.print("Gateway IP address is ");
  Serial.println(ip_to_str(gatewayAddr));
  
  Serial.print("DNS IP address is ");
  Serial.println(ip_to_str(dnsAddr));
}
#endif

// this method makes a HTTP connection to the server:
void sendData(int thisData) {
  // if there's a successful connection:
  if (herokuClient.connect()) {
    Serial.println("connecting to Heroku...");
    // send the HTTP PUT request. 

    herokuClient.print("POST /api/1/poll HTTP/1.1\n"); // TODO change to PUT
    herokuClient.print("Host: ");
    herokuClient.print(herokuHostName);
    herokuClient.print("\n");
    // fill in your Pachube API key here:
    herokuClient.print("X-PachubeApiKey: YOUR_KEY_HERE\n");
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

    // note the time that the connection was made:
    lastConnectionTime = millis();
    Serial.println("SUCCESS");
  } else {
    // if you couldn't make a connection:
    Serial.println("connection to Heroku failed");
  }
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
