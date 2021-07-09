//
//  SettingsViewController.swift
//  MQTTdemo
//
//  Created by YURY LVOV on 2019/11/06.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    let defaults = UserDefaults.standard
    @IBOutlet weak var ip_host: UITextField!
    @IBOutlet weak var rightEngine: UITextField!
    @IBOutlet weak var leftEngine: UITextField!
    @IBOutlet weak var rightEngineBack: UITextField!
    @IBOutlet weak var leftEngineBack: UITextField!
    @IBOutlet weak var streamIp: UITextField!
    @IBOutlet weak var streamPort: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ip_host.delegate = self
        self.rightEngine.delegate = self
        self.leftEngine.delegate = self
        self.rightEngineBack.delegate = self
        self.leftEngineBack.delegate = self
        self.streamIp.delegate = self
        self.streamPort.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Will appear")
        super.viewWillAppear(animated)
        let rpi_ip: String = self.defaults.string(forKey: "rpi_ip") ?? "192.168.1.2"
        let right_engine: String = self.defaults.string(forKey: "right_engine") ?? "95"
        let left_engine: String = self.defaults.string(forKey: "left_engine") ?? "100"
        let right_engine_back: String = self.defaults.string(forKey: "right_engine_back") ?? "95"
        let left_engine_back: String = self.defaults.string(forKey: "left_engine_back") ?? "100"
        let stream_ip: String = self.defaults.string(forKey: "string_ip") ?? "192.168.3.12"
        let stream_port: String = self.defaults.string(forKey: "string_port") ?? "8000"
        
        ip_host.text = rpi_ip
        rightEngine.text = right_engine
        leftEngine.text = left_engine
        rightEngineBack.text = right_engine_back
        leftEngineBack.text = left_engine_back
        streamIp.text = stream_ip
        streamPort.text = stream_port
    }
    
    @IBAction func ipHostChanged(_ sender: Any) {
        self.defaults.set(ip_host.text, forKey: "rpi_ip")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func setRightEnginePower(_ sender: Any) {
        self.defaults.set(Int(rightEngine.text!), forKey: "right_engine")
    }
    
    @IBAction func setLeftEnginePower(_ sender: Any) {
       self.defaults.set(Int(leftEngine.text!), forKey: "left_engine")
    }
    
    @IBAction func setRightEngineBackPower(_ sender: Any) {
        self.defaults.set(Int(rightEngineBack.text!), forKey: "right_engine_back")
    }
    
    @IBAction func setLeftEngineBackPower(_ sender: Any) {
       self.defaults.set(Int(leftEngineBack.text!), forKey: "left_engine_back")
    }
    
    @IBAction func streamingIpChanged(_ sender: Any) {
        self.defaults.set(Int(streamIp.text!), forKey: "stream_ip")
    }
    
    @IBAction func streamingPortChanged(_ sender: Any) {
        self.defaults.set(Int(streamPort.text!), forKey: "stream_port")
    }
}
