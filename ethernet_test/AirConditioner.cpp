/*
 * CloudComfort
 */

/*
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the
 * following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
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


  
