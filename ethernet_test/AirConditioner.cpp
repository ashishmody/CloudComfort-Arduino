/*
 * CloudComfort
 * (c) 2011
 */


#include "AirConditioner.h"

long Power = 0x4FB40BF;
long FanSpeed = 0x4FB58A7;
long TemperatureDown = 0x4FB8877;
long TemperatureUp = 0x4FB50AF;
long ModeChange = 0x4FB906F;
long Timer = 0x4FB9867;


//AirConditioner::AirConditioner() :
//  knownPowerStatus = 0;
//  knownTemperature = DEFAULT_TEMP;
//  knownFanSpeed = FAN_LOW;
//}

void AirConditioner::setPower(int powerStatus) {
  if (powerStatus == 0 || powerStatus == 1) // only valid values:
    if (powerStatus != knownPowerStatus) {
      // send IR code
      //irsend.sendNEC(Power, 32); // Toggle Power
      knownPowerStatus = powerStatus;
    }
}

void AirConditioner::setThermostat(int temperature) {
  if (temperature <= MIN_TEMP_VALUE)
    temperature = MIN_TEMP_VALUE;
  if (temperature > MAX_TEMP_VALUE)
    temperature = MAX_TEMP_VALUE;
  if (temperature != knownTemperature) {
    if (temperature > knownTemperature) {
      
      for (int i = knownTemperature; i < temperature; i++) {
        // send "temp++" IR code
        //irsend.sendNEC(TemperatureUp, 32); //Raise Temperature
      }
    } else {
      for (int i = knownTemperature; i > temperature; i--) {
        // send "temp--" IR code
        //irsend.sendNEC(TemperatureDown, 32); //Lower Temperature
      }
    }
  }
  knownTemperature = temperature;
}

void AirConditioner::setFanSpeed(int fanSpeed) {
  if (fanSpeed == FAN_LOW || fanSpeed == FAN_MEDIUM || fanSpeed == FAN_HIGH) {
    // send IR code
    //irsend.sendNEC(FanSpeed, 32); //Change Fan Speed
    knownFanSpeed = fanSpeed;
  }
}


  
