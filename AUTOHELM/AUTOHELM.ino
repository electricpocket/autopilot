/*
  Arduino Nano 33 BLE
*/

#include <ArduinoBLE.h>


#define BUTTON_DELAY 200

#define PORT_ONE 7 //pin 7 D4
#define STBD_ONE 10 //pin 10 D7
#define AUTO 11 //pin 11 D8

static const char* greeting = "Hello World!";

BLEService greetingService("180C");  // User defined service

BLEStringCharacteristic greetingCharacteristic("2A56",  // standard 16-bit characteristic UUID
    BLERead, 13); // remote clients will only be able to read this


BLEStringCharacteristic autohelmCharacteristic("FFF2",  // standard 16-bit characteristic UUID
    BLERead | BLEWrite,6); // remote clients will be able to read & write this


void switchCharacteristicWritten(BLEDevice central, BLECharacteristic characteristic) {
  // central wrote new value to characteristic, update LED
  Serial.print("Characteristic event, written: ");
  String val = (char*)(characteristic.value());
  switch (val.charAt(0)) {
        case '1':
          pressButton(PORT_ONE);
          break;
        case '2':
          pressButton(STBD_ONE);
          break;
        case '3':
          pressButton(AUTO);
          break;
        default:
          Serial.print("Unknown command: ");
          Serial.println(val);
          break;    

    }
}

void pressButton(int pin){
  digitalWrite(pin, HIGH);
  delay(BUTTON_DELAY);
  digitalWrite(pin, LOW);
}

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin

  //Init output pins
  pinMode(PORT_ONE, OUTPUT);
  digitalWrite(PORT_ONE, LOW);

  pinMode(STBD_ONE, OUTPUT);
  digitalWrite(STBD_ONE, LOW);

  pinMode(AUTO, OUTPUT);
  digitalWrite(AUTO, LOW);

  if (!BLE.begin()) {   // initialize BLE
    Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("Autohelm");  // Set name for connection
  BLE.setAdvertisedService(greetingService); // Advertise service
  // assign event handlers for characteristic
  autohelmCharacteristic.setEventHandler(BLEWritten, switchCharacteristicWritten);

  
  greetingService.addCharacteristic(greetingCharacteristic); // Add characteristic to service
  greetingService.addCharacteristic(autohelmCharacteristic); // Add characteristic to service
  BLE.addService(greetingService); // Add service
  greetingCharacteristic.setValue(greeting); // Set greeting string

  BLE.advertise();  // Start advertising
  Serial.print("Peripheral device iPhone: ");
  Serial.println(BLE.address());
  Serial.println("Waiting for connections...");
}

void loop() {
  BLEDevice central = BLE.central();  // Wait for a BLE central to connect

  // if a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central iPhone: ");
    // print the central's BT address:
    Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected())
    {
      //handle autohelm commands 
    }// keep looping while connected
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central iPhone: ");
    Serial.println(central.address());
  }
}
  
