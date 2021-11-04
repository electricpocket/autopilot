# Bluetooth iOS remote for Navico TP5000

This project is for an iOS Bluetooth remote control for the Navico TP5000 autopilot

<img src="https://user-images.githubusercontent.com/463068/140337885-da3f190a-4a87-4f6d-9f18-b0aabbac31da.jpeg" alt="App and TP5000" width="500"/>

[Video of the app in action](https://youtu.be/SloeDqlF8rE)

## Design
The basic idea was to mount a bluetooth module inside the Navico TP5000 that would communicate with an iPhone iOS app to send instructions via Bluetooth LE to the TP5000 to turn to port or starboard.

Attempts to talk to and control the TP5000 over NMEA0183 via the yellow/green NMEA wires on the power lead failed, so instead the other obvious but less elegant solution of simulating the three button presses, port, starboard and Auto, on the TP5000 with relays was adopted.

### Components
- 1 x Arduino Nano33 BLE https://www.arduino.cc/en/Guide/NANO33BLE
- 3 x 3-5V NO Reed Relays -  D31A3100 SPST NO relay 500ohms coil resistance =>  10mA switching current at 5V https://uk.rs-online.com/web/p/reed-relays/1782703/
- 1 Relay driver board - 3 Channel 3.3V/5V 10A Relay Module for Arduino RPi ESP8266 + Optocoupler https://www.ebay.co.uk/itm/272607156352
- 1 5V regulator 78L05 - https://www.ebay.co.uk/itm/121681683380

## Development
### Software
#### Arduino app
The latest Arduino IDE 1.8.16 was used for the project (not that it should matter which version is used) together with this getting started guide to help:-

https://www.arduino.cc/en/Guide/NANO33BLE

The Ardiuno app source code is included wih this project. It controls the relays via 3 digital output pins (D2,D3 & D4; physical pins 5,6 & 7) from the Arduino and an analogue input pin (A0; pin 19)to monitor the Auto status light on the TP5000. 

#### iOS app
An iOS app was developed to send commands via Bluetooth to the Nano. The code built on this example https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift from Ray Wenderlich. The iOS app soure code is included in this project.

![IMG_FEFDF58D98D4-1 copy](https://user-images.githubusercontent.com/463068/140384308-61348422-f51a-4e76-9f9e-912448f3bdbc.png)

The 12V supply inside the TP5000 (from the back of the remote port socket) was used to power the Nano33 BLE ( the Nano can use anything from. 3.3 to 30V to power it!).

The 3 relays were solderd to the back of the microswitches on the TP5000 switch and led board.

Small reed relays with the highest drive impedance (hence lowest current -  10mA) were chosen but unfortunately the Nano33 just could not drive the relays using its 3.3V digital output pins directly so a relay driver board and a 5V regulator were added to drive them indirectly. The large relays that came on the board were removed and the board cut in half ( at the line where the connection to the relay driver pins is) so that it would fit inside the TP5000. The output driver pins were wired to the relays on the back to the TP5000 controller board. The +3.3V regulated output from the Nano (pin 17) was still not powerful enough to drive the relays so a 5V supply was added. The 5V regulator was attached to the 12V power supply rather than try to find and attach to a 5V supply on the main TP5000 circuit board.

Here is the Arduino Nano33 BLE pin out (Note the pin labels are the constant names used in the Arduino app - e.g. physical pin5 is software pin D2).

<img width="574" alt="Screenshot 2021-11-04 at 15 35 49" src="https://user-images.githubusercontent.com/463068/140360352-0740f7b8-dcc0-4869-835b-e54d204a1956.png">

Fitting the Nano and the Relay driver board and all the wires inside the TP5000 housing was a bit of a struggle. Some judicous application of hot glue to hold things in place helped. And voila:-

[Video of the app in action](https://youtu.be/SloeDqlF8rE)

