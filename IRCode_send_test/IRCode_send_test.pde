/*
 * Program to send commands to the Air Conditioner. Acts as the AC Remote.
 * Based on the IRremote library.
 */
/*
 * IRremote: IRsendDemo - demonstrates sending IR codes with IRsend
 * An IR LED must be connected to Arduino PWM pin 3.
 * Version 0.1 July, 2009
 * Copyright 2009 Ken Shirriff
 * http://arcfn.com
 */

#include <IRremote.h>

IRsend irsend;
long Power = 0x4FB40BF;
long FanSpeed = 0x4FB58A7;
long TemperatureDown = 0x4FB8877;
long TemperatureUp = 0x4FB50AF;
long ModeChange = 0x4FB906F;
long Timer = 0x4FB9867;


void setup()
{
  Serial.begin(9600);
}

void loop() {
    Serial.println("Power Up");
    irsend.sendNEC(Power, 32); // Power Up the AC
    delay(10000);
    Serial.println("Changing Fan Speed");
    irsend.sendNEC(FanSpeed, 32); //Change Fan Speed
    delay(10000);
    Serial.println("Raise Temp");
    irsend.sendNEC(TemperatureUp, 32); //Raise Temperature
    delay(10000);
    Serial.println("Lower Temp");
    irsend.sendNEC(TemperatureDown, 32); //Lower Temperature
    delay(10000);
    Serial.println("Turn Off");
    irsend.sendNEC(Power, 32); //Turn Off
    delay(10000);
}

