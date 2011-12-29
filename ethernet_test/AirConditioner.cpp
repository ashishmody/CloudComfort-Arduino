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

void AirConditioner::setupTemp() {
  int i = 0;
  while (i != 15) {
    irsend.sendNEC(TemperatureDown, 32); // Toggle Power
    i++;
  }
}
void AirConditioner::setPower(int powerStatus) {
  Serial.print("Power status to be set is : ");
  Serial.println(powerStatus);
  if (powerStatus == 0 || powerStatus == 1) // only valid values:
    if (powerStatus != knownPowerStatus) {
      // send IR code
      Serial.print("Setting Power Status");
      Serial.println(powerStatus);
      irsend.sendNEC(Power, 32); // Toggle Power
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
        Serial.print("Sending Temp++");
        irsend.sendNEC(TemperatureUp, 32); //Raise Temperature
      }
    } else {
      for (int i = knownTemperature; i > temperature; i--) {
        // send "temp--" IR code
        Serial.print("Sending Temp --");
        irsend.sendNEC(TemperatureDown, 32); //Lower Temperature
      }
    }
  }
  knownTemperature = temperature;
}

void AirConditioner::setFanSpeed(int fanSpeed) {
  if (fanSpeed == FAN_LOW || fanSpeed == FAN_MEDIUM || fanSpeed == FAN_HIGH || fanSpeed == FAN_AUTO) {
    // send IR code
    Serial.print("Setting Fan Speed");
    Serial.println(fanSpeed);
    irsend.sendNEC(FanSpeed, 32); //Change Fan Speed
    knownFanSpeed = fanSpeed;
  }
}


  
