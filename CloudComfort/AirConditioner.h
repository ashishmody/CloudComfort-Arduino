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


#ifndef AirConditioner_class_h
#define AirConditioner_class_h
#ifdef __cplusplus

#include "IRremote.h"
#include "Arduino.h"

const int FAN_LOW = 0;
const int FAN_MEDIUM = 1;
const int FAN_HIGH = 2;
const int FAN_AUTO = 3;

const int MIN_TEMP_VALUE = 19;
const int MAX_TEMP_VALUE = 31;
/**
 * This is the default power-on temperature setting for the Air Conditioner unit.
 */
const int DEFAULT_TEMP = 24;

class AirConditioner {

 public:
  /**
   * Set the air conditioner power to On (1) or Off (0). Any other values are ignored.
   */
  void setPower(int powerStatus);

  /**
   * Set the desired temperature for the thermostat, in degrees Celsius. Values are clamped between XX and YY, inclusive.
   * @param temperature Degrees Celsius.
   */
  void setThermostat(int temperature);

  /**
   * Set the fan speed for the air conditioner. Valid values are [0..2], invalid values are ignored.
   * @param speed An integer between 0 (zero) and 2 (two), inclusive, representing Low, Medium, and High.
   */
  void setFanSpeed(int speed);
  void setupTemp();

 protected:
  int knownPowerStatus;
  int knownTemperature;
  int knownFanSpeed;
  IRsend irsend;
};

#endif
#endif
