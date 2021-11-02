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
    @IBOutlet weak var modeStatus: UILabel!
    @IBOutlet weak var modeLight: UIImageView!
    @IBOutlet weak var autoLight: UIImageView!
    
    //let connectionManager : ConnectionManager = ConnectionManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //TODO: Watch Bluetooth connection
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.connectionChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.modeChanged(_:)), name: NSNotification.Name(rawValue: BLEServiceModeStatusNotification), object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance.startScanning()
        self.modeStatus.text = "automode status unknown"
        //self.modeLight.image = (UIImage(named:"redOff"))
        self.setBTDiscoveryImage()
        self.autoLight.image = (UIImage(named:"redOff"))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceChangedStatusNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: BLEServiceModeStatusNotification), object: nil)
    }

    

    @IBAction func plusOnePressed(sender: AnyObject) {
        sendMessage(message: "11")
    }
    
    @IBAction func plusOneReleased(sender: AnyObject) {
        sendMessage(message: "21")
    }
    
    @IBAction func minusOnePressed(sender: AnyObject) {
        sendMessage(message: "12")
    }
    
    @IBAction func minusOneReleased(sender: AnyObject) {
        sendMessage(message: "22")
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
    
    func readMessage() {
        // Read analogue Mode value BLE Shield (if service exists and is connected)
        if let bleService = btDiscoverySharedInstance.bleService {
            bleService.readMessage()
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
            self.modeLight.stopAnimating()
            self.modeLight.image = (UIImage(named:"btOn"))
            
            
          } else {
            self.connectionStatus.text = "Not connected"
            //self.modeLight.image = (UIImage(named:"btOff"))
            self.setBTDiscoveryImage()
          }
        }
      });
    }
    
    @objc func modeChanged(_ notification: Notification) {
      // Autom mode light tatus changed. Indicate on GUI.
      let userInfo = (notification as NSNotification).userInfo as! [String: String]
      
      DispatchQueue.main.async(execute: {
        // Set image based on connection status
    
        self.modeStatus.text = userInfo["modeStatus"]
        let voltage = Double(userInfo["modeStatus"] ?? "0.0")
        if (voltage ?? 0.0 > 270.0)
        {
            self.autoLight.image = (UIImage(named:"redOn"))
        }
        else {
            self.autoLight.image = (UIImage(named:"redOff"))
        }
        
      });
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBTDiscoveryImage()
    {
        self.modeLight.animationImages = self.animatedImages(for: "bt")
        self.modeLight.animationDuration = 0.9
        self.modeLight.animationRepeatCount = 0
        self.modeLight.image = self.modeLight.animationImages?.first
        self.modeLight.startAnimating()
    }
    
    
    func animatedImages(for name: String) -> [UIImage] {
        
        var i = 0
        var images = [UIImage]()
        let imName = "\(name)\(i)"
        while let image = UIImage(named: "\(name)\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }

}

