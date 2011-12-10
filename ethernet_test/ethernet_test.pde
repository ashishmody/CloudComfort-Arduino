// -*- mode:c -*-
/*
 * CloudComfort
 * (c) 2011
 */

#define STATIC_IP 1
#define DHCP 0
#define PUSHER_CLIENT_ID YOUR_PUSHER_CLIENT

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
//byte server[] = { 107,22,234,17 }; // Google
PusherClient client("PUSHER_CLIENT_ID");

boolean static isIPValid = false;
boolean static didClientConnect = false;
//Client client(server, 80);

void setup() {
  Serial.begin(9600);
  Serial.println("BOOT");

#ifdef STATIC_IP
  Ethernet.begin(mac, ip);
  Serial.print("Static IP: ");
  Serial.println(ip_to_str(ip));
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
    if (!didClientConnect) {
      Serial.print("Starting Client Connection..");
      if (client.connect()) {
        Serial.println("connected");
        client.bindAll(ac);
        client.subscribe("cloudcomfort");
        didClientConnect = true;
	Serial.println("connected");
      } else {
	Serial.println("failed");
        // if you didn't get a connection to the server:
        while (1) {
          Serial.println("didnt connect. plz reset.");
        }
      }
    } else {
      // if there are incoming bytes available 
      // from the server, read them and print them:
      if (client.connected()) {
	client.monitor();
      } else {
	didClientConnect = false;
	Serial.println("in loop! not connected"); 
      }
    }
    /*
    // if the server's disconnected, stop the client:
    if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");

    // do nothing forevermore:
    for(;;)
      ;
  }*/
  }
}

void sendSensorValues() {
  // Make a HTTP request:
  //client.println("POST http://electric-beach-9373.heroku.com/api/1/poll HTTP/1.1");
  //client.println("tempc:63");
  //client.println();
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
