//
//  BTDiscovery.swift
//  autopilot
//
//  Created by Lars Jessen on 24/07/15. Based on Owen L Brown's example https://www.raywenderlich.com/85900/arduino-tutorial-integrating-bluetooth-le-ios-swift
//  Copyright (c) 2015 Lars Jessen. All rights reserved.
//

import Foundation
import CoreBluetooth


let btDiscoverySharedInstance = BTDiscovery();

class BTDiscovery: NSObject, CBCentralManagerDelegate {
  
  private var centralManager: CBCentralManager?
  private var peripheralBLE: CBPeripheral?
  
  override init() {
	super.init()
    let centralQueue = DispatchQueue(label: "com.pocketmariner", attributes: [])
	centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    print("BT Discovery started")
  }
    
    func startScanning() {
      if let central = centralManager {
        central.scanForPeripherals(withServices: [BLEServiceUUID], options: nil)
      }
    }
    
    var bleService: BTService? {
      didSet {
        if let service = self.bleService {
          service.startDiscoveringServices()
        }
      }
    }

 
  
  // MARK: - CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
    
    
    print("centralManager start")
    
    // Be sure to retain the peripheral or it will fail during connection.
    
    // Validate peripheral information
    if ((peripheral.name == nil) || (peripheral.name == "")) {
      return
    }
    
    // If not already connected to a peripheral, then connect to this one
    if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.disconnected)) {
      // Retain the peripheral before trying to connect
      self.peripheralBLE = peripheral
      
      // Reset service
      self.bleService = nil
      
      // Connect to peripheral
        central.connect(peripheral, options: nil)
    }
  }
  
 func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      
      // Create new service class
      if (peripheral == self.peripheralBLE) {
        self.bleService = BTService(initWithPeripheral: peripheral)
      }
      
      // Stop scanning for new devices
      central.stopScan()
    }
  
func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
      
      // See if it was our peripheral that disconnected
      if (peripheral == self.peripheralBLE) {
        self.bleService = nil;
        self.peripheralBLE = nil;
      }
      
      // Start scanning for new devices
      self.startScanning()
    }
  
  // MARK: - Private
  
  func clearDevices() {
    self.bleService = nil
    self.peripheralBLE = nil
  }
  
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    print("centralManager did update state")
    switch (central.state) {
    case .poweredOff:
      self.clearDevices()
      
    case .unauthorized:
      // Indicate to user that the iOS device does not support BLE.
      break
      
    case .unknown:
      // Wait for another event
      break
      
    case .poweredOn:
      self.startScanning()
      
    case .resetting:
      self.clearDevices()
      
    case .unsupported:
      break
    @unknown default:
        print("centralManager unknown new state")
        break
    }
  }

}
