/*

  -Papaoutai-

  Monitors time spent in bathroom
  "Battery Monitor" Example used as framework for BLE connection.

  Connects to phone via BLE to record time when within proximity of Arduino Nano
  On BLE disconnection from iphone, iOS app sends time data to MongoDB via node.js

*/

#include <ArduinoBLE.h>

BLEService arduinoService("2EF7378E-E6A3-85B0-FC27-F82005E222B1");
BLEIntCharacteristic rssiChar("4170bbdd-8b46-48ab-9189-0bda5a295589", 
     BLERead); 

long previousMillis = 0;  // last time the battery level was checked, in ms
int oldRSSILevel = -100;
int RSSILIMIT = -200;
int counter = 0;

void setup() {
  delay(500);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when iphone is connected

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }

  BLE.setDeviceName("Nano");
  BLE.setLocalName("Papaoutai");
  
  BLE.addService(arduinoService); 
  BLE.setAdvertisedService(arduinoService);
  
  arduinoService.addCharacteristic(rssiChar);
  rssiChar.writeValue(oldRSSILevel);

  BLE.advertise();
}

void loop() {
  // wait for a BLE central
  BLEDevice central = BLE.central();

  // if a central is connected to the peripheral:
  if (central) {
    
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // read RSSI every 200ms while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();
      
      // if 500ms have passed, update RSSI:
      if (currentMillis - previousMillis >= 500) {
        previousMillis = currentMillis;
        updateRssiCharacteristic();
        if (isDeviceInRange()) {
          counter += 1;
        } else {
          continue;
        }
      }
    }
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
  }
}

bool isDeviceInRange() {
  if (BLE.rssi() > RSSILIMIT) {
    return true;
  } else {
    return false;
  }
}

void updateRssiCharacteristic(){
  if (BLE.rssi() != oldRSSILevel) {
    rssiChar.writeValue(BLE.rssi() * -1);
    oldRSSILevel = BLE.rssi();
  }
}
