#include <EthernetBonjour.h>

#include <EthernetDHCP.h>

#include <SPI.h>

#include <Client.h>
#include <Ethernet.h>
#include <Server.h>
#include <Udp.h>



//byte ip[] = {192,168,4,233};
byte mac[] = {0x90, 0xa2, 0xda, 0x00, 0x87, 0xde};
byte gateway[] = { 10, 16, 35, 1 }; //MY DSL DEVICE
byte subnet[] = { 255, 255, 255, 0 }; //MY SUBNET MASK
const char* ip_to_str(const uint8_t*);
Server server(80);

void setup() {
  Serial.begin(9600);

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
  //Ethernet.begin(mac, ip, gateway, subnet);
  server.begin();
}

void loop()
{
  // listen for incoming clients
  Client client = server.available();
  if (client) {
    digitalWrite(2, LOW);
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println();

          // output the value of each analog input pin
          for (int analogChannel = 0; analogChannel < 6; analogChannel++) {
            client.print("analog input ");
            client.print(analogChannel);
            client.print(" is ");
            client.print(analogRead(analogChannel));
            client.println("<br />");
          }
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } 
        else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
  }
  else {
    //digitalWrite(2, LOW);
  }
}

// Just a utility function to nicely format an IP address.
const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}
