/*
  Arduino Nano 33 BLE
*/

#include <ArduinoBLE.h>


#define BUTTON_DELAY 150

#define PORT_ONE 2 //pin 5 D2
#define STBD_ONE 3 //pin 6 D3
#define AUTO 4 //pin 7 D4
#define STATUS_CHECK_TIME 250 //check the status light voltage every 250ms

static const char* greeting = "Hello World!";
int sensorPin = A0;    // Anaolgue select the input pin for led flashing light on the Navico
float modeOnLevel = 270; //anaolgue voltage reading for high : 1024*1.4/3.3 = 424
bool modeStatus = false;

BLEService autohelm("180C");  // User defined service

BLEStringCharacteristic autoModeCharacteristic("2A56",  // standard 16-bit characteristic UUID
    BLERead | BLENotify, 13); // remote clients will only be able to read this


BLEStringCharacteristic autohelmCharacteristic("FFF2",  // standard 16-bit characteristic UUID
    BLERead | BLEWrite,6); // remote clients will be able to read & write this

void  modeCharacteristicRead(BLEDevice central, BLECharacteristic characteristic) {
  // central requested new value from characteristic
  Serial.print("Mode Characteristic event, read: ");
  String val = autoModeCharacteristic.value();
  Serial.println(val);
  float autoValue = analogRead(sensorPin);
  autoModeCharacteristic.setValue(String(autoValue)); // Set greeting string
  Serial.print("Read analogue: ");
  Serial.println(String(autoValue));
}

void switchCharacteristicWritten(BLEDevice central, BLECharacteristic characteristic) {
  // central wrote new value to characteristic, update LED
  Serial.print("Characteristic event, written: ");
  String val = (char*)(characteristic.value());
  Serial.println(val.charAt(0));
  Serial.println(millis());
  switch (val.charAt(0)) {
        case '1':
          digitalWrite(PORT_ONE, HIGH);
          break;
        case '2':
          digitalWrite(STBD_ONE, HIGH);
          break;
        case '3':
          digitalWrite(AUTO, HIGH);
          break;
        case '4':
          digitalWrite(PORT_ONE, LOW);
          break;
        case '5':
          digitalWrite(STBD_ONE, LOW);
          break;
        case '6':
          digitalWrite(AUTO, LOW);
          break;
        case '7':
          pressButton(PORT_ONE);
          break;
        case '8':
          pressButton(STBD_ONE);
          break;
        case '9':
          pressButton(AUTO);
          break;
        case '0': //clear all
          digitalWrite(PORT_ONE, LOW);
          digitalWrite(STBD_ONE, LOW);
          digitalWrite(AUTO, LOW);
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
  //Serial.begin(9600);    // initialize serial communication
  //while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin
  //Init output pins
  pinMode(PORT_ONE, OUTPUT);
  digitalWrite(PORT_ONE, LOW);

  pinMode(STBD_ONE, OUTPUT);
  digitalWrite(STBD_ONE, LOW);

  pinMode(AUTO, OUTPUT);
  digitalWrite(AUTO, LOW);

  if (!BLE.begin()) {   // initialize BLE
    //Serial.println("starting BLE failed!");
    while (1);
  }

  BLE.setLocalName("Autohelm");  // Set name for connection
  BLE.setAdvertisedService(autohelm); // Advertise service
  // assign event handlers for characteristic
  autohelmCharacteristic.setEventHandler(BLEWritten, switchCharacteristicWritten);
  autoModeCharacteristic.setEventHandler(BLERead, modeCharacteristicRead);
  
  autohelm.addCharacteristic(autohelmCharacteristic); // Add characteristic to service
  autohelm.addCharacteristic(autoModeCharacteristic); // Add characteristic to service
  
  BLE.addService(autohelm); // Add service
  
  float sensorValue = analogRead(sensorPin);
  autoModeCharacteristic.setValue(String(sensorValue)); // Set greeting string

  BLE.advertise();  // Start advertising
  //Serial.print("Peripheral device iPhone: ");
  //Serial.println(BLE.address());
  //Serial.println("Waiting for connections...");
  Serial.print("Read analogue: ");
  Serial.println(String(sensorValue));
}

void loop() {
  BLEDevice central = BLE.central();  // Wait for a BLE central to connect

  // if a central is connected to the peripheral:
  if (central) {
    //Serial.print("Connected to central iPhone: ");
    // print the central's BT address:
    //Serial.println(central.address());
    // turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);
    unsigned long relayStartMills = millis();
    while (central.connected())
    {
      if (millis() - relayStartMills >=  STATUS_CHECK_TIME)
      {
        float autoValue = analogRead(sensorPin);
      
        if (( autoValue > modeOnLevel) and (modeStatus == false))
        {
          modeStatus = true;
          autoModeCharacteristic.setValue(String(autoValue)); // Set greeting string 
          Serial.println("ModeOn"); 
        }
        else if (( autoValue <= modeOnLevel) and (modeStatus != false))
        {
          modeStatus = false;
          autoModeCharacteristic.setValue(String(autoValue)); // Set greeting string  
          Serial.println("ModeOff"); 
        }
      
        //Serial.print("Read analogue: ");
        //Serial.println(String(autoValue));
        //don't sleep otherwise the digital interrupts get delayed
      }
      //handle autohelm commands 
    }// keep looping while connected
    
    // when the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    digitalWrite(PORT_ONE, LOW);
    digitalWrite(STBD_ONE, LOW);
    digitalWrite(AUTO, LOW);
    //Serial.print("Disconnected from central iPhone: ");
    //Serial.println(central.address());
  }
}
  
