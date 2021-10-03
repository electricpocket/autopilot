//
//  BTService.swift
//  autopilot
//
//  Created by Lars Jessen on 24/07/15. Based on Owen L Brown's example https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift
//  Copyright (c) 2015 Lars Jessen. All rights reserved.
//

import Foundation
import CoreBluetooth

/* Services & Characteristics UUIDs */
let BlueduinoUUID = NSUUID(uuidString: "7AF496E9-0415-E383-4EDB-9E948F2C8966")
let BLEServiceUUID = CBUUID(string: "180C") // "7AF496E9-0415-E383-4EDB-9E948F2C8966"
let TxCharUUID = CBUUID(string: "FFF2")

let BLEServiceChangedStatusNotification = "kBLEServiceChangedStatusNotification"

class BTService: NSObject, CBPeripheralDelegate {
  var peripheral: CBPeripheral?
  var positionCharacteristic: CBCharacteristic?
  
  init(initWithPeripheral peripheral: CBPeripheral) {
    super.init()
    
    self.peripheral = peripheral
    self.peripheral?.delegate = self
  }
  
  deinit {
    self.reset()
  }
  
  func startDiscoveringServices() {
    print("starts discovering services")
    self.peripheral?.discoverServices([BLEServiceUUID])
  }
  
  func reset() {
    if peripheral != nil {
      peripheral = nil
    }
    
    // Deallocating therefore send notification
    self.sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: false)
  }
  
  // Mark: - CBPeripheralDelegate
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print("peripheral services")
    let uuidsForBTService: [CBUUID] = [TxCharUUID]
    
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      print("wrong peripheral")
      return
    }
    
    if (error != nil) {
        print(error?.localizedDescription ?? "unknown error")
      return
    }
    
    if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
      print("no services")
      // No Services
      return
    }
    
    for service in peripheral.services! {
        if service.uuid == BLEServiceUUID {
        print("starts characteristics discovery...")
            peripheral.discoverCharacteristics(uuidsForBTService, for: service)
      }
    }
  }
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)  {
    if (peripheral != self.peripheral) {
      // Wrong Peripheral
      return
    }
    
    if (error != nil) {
      return
    }
    
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        if characteristic.uuid == TxCharUUID {
          self.positionCharacteristic = (characteristic)
            peripheral.setNotifyValue(true, for: characteristic)
          
          // Send notification that Bluetooth is connected and all required characteristics are discovered
            self.sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: true)
        }
      }
    }
  }
  
  // Mark: - Private
  
  func sendMessage(message: String) {
    // See if characteristic has been discovered before writing to it
    if let positionCharacteristic = self.positionCharacteristic {
      // Need a mutable var to pass to writeValue function
        let data = message.data(using:  String.Encoding.utf8)
        self.peripheral?.writeValue(data!, for: positionCharacteristic, type: CBCharacteristicWriteType.withResponse)
      
    }
  }
  
  func sendBTServiceNotificationWithIsBluetoothConnected(isBluetoothConnected: Bool) {
    let connectionDetails = ["isConnected": isBluetoothConnected]
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification) , object: self, userInfo: connectionDetails)
  }
  
}
