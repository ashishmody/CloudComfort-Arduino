
/*
 * CloudComfort
 * (c) 2011
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
  void setThermostat(int temperature, int ACTemp);

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
