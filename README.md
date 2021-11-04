# Bluetooth iOS remote for Navico TP5000

This project is for an iOS Bluetooth remote control for the Navico TP5000 autopilot

<img src="https://user-images.githubusercontent.com/463068/140337885-da3f190a-4a87-4f6d-9f18-b0aabbac31da.jpeg" alt="App and TP5000" width="500"/>

[Video of the app in action](https://youtu.be/SloeDqlF8rE)

## Design
The basic idea was to mount a bluetooth module inside the Navico TP5000 that would communicate with an iPhone iOS app which could send instructions via Bluetooth LE to the TP5000 to turn to port or starboard.

Attempts to talk to and control the TP5000 over NMEA0183 via the yellow/green NMEA wires on the power lead failed, so instead we went for the other obvious but less elegant solution of simulating the three button presses, port, starboard and Auto, on the TP5000 with relays.

### Components
- 1 x Arduino Nano33 BLE https://www.arduino.cc/en/Guide/NANO33BLE
- 3 x 3-5V NOReed Relays -  D31A3100 SPST NO relay 500ohms coil resistance =>  10mA switching current at 5V https://uk.rs-online.com/web/p/reed-relays/1782703/
- 1 Relay driver board - 3 Channel 3.3V/5V 10A Relay Module for Arduino RPi ESP8266 + Optocoupler https://www.ebay.co.uk/itm/272607156352
- 1 5V regulator 78L05 - https://www.ebay.co.uk/itm/121681683380

## Development
### Software
#### Arduino app
We used the latest Arduino IDE 1.8.16 for the project (not that it should matter which version you use) and used this getting started guide to help:-

https://www.arduino.cc/en/Guide/NANO33BLE

We wrote a simple Ardiuno app ( code in this project ) to control the relays via 3 digital output pins (D2,D3 & D4; physical pins 5,6 & 7) from the Arduino and an analogueinput pin (A0; pin 19)to monitor the Auto status light on the TP5000. 

#### iOS app
We then wrote an iOS app to send commands via Bluetooth to the Nano 
based the code largely on [this example](https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift) from Ray Wenderlich.

## Hardware
We used the 12V supply inside the TP5000 (from the back of the remote port socket) to power the Nano33 BLE ( the Nano can use anything from. 3.3 to 30V to power it!).
We soldered the 3 relays to the back of the microswitches on the TP5000 switch and led board.

We had chosen small reed relays with the highest drive impedance (hence lowest current -  10mA) we could find but unfortunately found the Nano33 could not drive the relays using 3.3V digital output pins directly so we had to add a relay driver board and a 5V regulator to drive them indirectly. We removed the large relays that came on the board and cut it in half ( at the line where the connection to the relay driver pins is) so that it would fit inside the TP5000. The output driver pins were wired to the relays on the back to the TP5000 controller board. The +3.3V regulated output from the Nano (pin 17) was still not powerful enough to drive the relays so we had to add a 5V supply. The 5V regulator was attached to the 12V power supply rather than try to find and attach to a 5V supply on the main TP5000 circuit board.

Arduino Nano33 BLE 
<img width="574" alt="Screenshot 2021-11-04 at 15 35 49" src="https://user-images.githubusercontent.com/463068/140360352-0740f7b8-dcc0-4869-835b-e54d204a1956.png">

