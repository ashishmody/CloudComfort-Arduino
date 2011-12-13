/*
 * CloudComfort
 * (c) 2011
 */

#ifndef AirConditioner_class_h
#define AirConditioner_class_h
#ifdef __cplusplus

//#include <IRremote.h>

const int FAN_LOW = 0;
const int FAN_MEDIUM = 1;
const int FAN_HIGH = 2;

const int MIN_TEMP_VALUE = 20;
const int MAX_TEMP_VALUE = 30;
/**
 * This is the default power-on temperature setting for the Air Conditioner unit.
 */
const int DEFAULT_TEMP = 12;

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

 protected:
  int knownPowerStatus;
  int knownTemperature;
  int knownFanSpeed;
  //IRsend irsend;
};

#endif
#endif
