//
//  ViewController.swift
//  autopilot
//
//  Created by Lars Jessen on 24/07/15.
//  Copyright (c) 2015 Lars Jessen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var plusOne: UIButton!
    @IBOutlet weak var minusOne: UIButton!
    @IBOutlet weak var plusTen: UIButton!
    @IBOutlet weak var minusTen: UIButton!
    @IBOutlet weak var auto: UIButton!
    @IBOutlet weak var standby: UIButton!
    @IBOutlet weak var connectionStatus: UILabel!
    
    //let connectionManager : ConnectionManager = ConnectionManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //TODO: Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance.startScanning()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
    }

    

    @IBAction func plusOnePressed(sender: AnyObject) {
        sendMessage(message: "1")
    }
    
    @IBAction func minusOnePressed(sender: AnyObject) {
        sendMessage(message: "2")
    }
    
    @IBAction func plusTenPressed(sender: AnyObject) {
        sendMessage(message: "4")
    }
    
    @IBAction func minusTenPressed(sender: AnyObject) {
        sendMessage(message: "5")
    }
    
    @IBAction func autoPressed(sender: AnyObject) {
        sendMessage(message: "3")
    }
    
    @IBAction func standbyPressed(sender: AnyObject) {
        sendMessage(message: "6")
    }
    
    func sendMessage(message: String) {
        // Send position to BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.sendMessage(message: message)
        }
    }

    

    @objc func connectionChanged(_ notification: Notification) {
      // Connection status changed. Indicate on GUI.
      let userInfo = (notification as NSNotification).userInfo as! [String: Bool]
      
      DispatchQueue.main.async(execute: {
        // Set image based on connection status
        if let isConnected: Bool = userInfo["isConnected"] {
          if isConnected {
            self.connectionStatus.text = ""
            
            
          } else {
            self.connectionStatus.text = "Not connected"
          }
        }
      });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

