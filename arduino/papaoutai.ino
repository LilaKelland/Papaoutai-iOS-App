/*

  -Papaoutai-

  Monitors time spent in bathroom
  "Battery Monitor" Example used as framework for BLE connection.

  Connects to phone via BLE to record time when within proximity of Arduino Nano
  On BLE disconnection from iphone, Arduino sends time data to python API via wifi.*** this is not the case anymore - wifi and ble cant be used concurrently

*/

#include <ArduinoBLE.h>

BLEService arduinoService("2EF7378E-E6A3-85B0-FC27-F82005E222B1");
BLEIntCharacteristic rssiChar("4170bbdd-8b46-48ab-9189-0bda5a295589", 
     BLERead); 
// BLEIntCharacteristic timeChar("a50b0285-0604-422e-bb15-38bce91e5f5b", 
//     BLERead | BLEWrite| BLENotify); 

long previousMillis = 0;  // last time the battery level was checked, in ms
int oldRSSILevel = -100;
int RSSILIMIT = -45;
int counter = 0;

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when iphone is connected

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");

    while (1);
  }

  
  BLE.setLocalName("Papaoutai");
  BLE.setAdvertisedService(arduinoService);
  arduinoService.addCharacteristic(rssiChar);
  BLE.setDeviceName("Nano");
  BLE.addService(arduinoService); // Add the service
  rssiChar.writeValue(oldRSSILevel);

  BLE.advertise();

  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
  // wait for a BLE central
  BLEDevice central = BLE.central();

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's BT address:
    Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // read RSSI every 200ms while the central is connected:
    while (central.connected()) {
      long currentMillis = millis();
      // if 500ms have passed, update RSSI:
      if (currentMillis - previousMillis >= 500) {
        previousMillis = currentMillis;
        updateRssiCharacteristic();
        Serial.print("rssiChar Value: ");
        Serial.println(rssiChar.value());
        if (isDeviceInRange()) {
          Serial.print("in ");
          counter += 1;
        } else {
          Serial.print("out ");
          stopTimer();
          updateTimeStamp();
        }
      }
    }
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    // sendTimeRecoded()
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

void updateTimer() {

}

void stopTimer() {

}

void updateTimeStamp() {

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
    Serial.print("RSSI: ");
    Serial.println(BLE.rssi());
    rssiChar.writeValue(BLE.rssi() * -1);
    // Serial.print(rssiCharacteristic.value());
    oldRSSILevel = BLE.rssi();
  }
}
