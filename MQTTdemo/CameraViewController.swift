//
//  CameraViewController.swift
//  MQTTdemo
//
//  Created by YURY LVOV on 2019/11/13.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import CDJoystick

class CameraViewController: MqttConnectorController {
    
    @IBOutlet weak var cameraJoystickIcon: UIButton!
    @IBOutlet weak var cameraJoystick: CDJoystick!
    
    var current_command: String = "stop"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        _ = self.mqttClient.connect()
        cameraJoystick.trackingHandler = { joystickData in
            if (
                Double(joystickData.angle) > Double.pi*1/4 &&
                    Double(joystickData.angle) < Double.pi*3/4
                )
            {
                if self.current_command != "camera_right" {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "camera_right", x: 0, y: 0))
                    self.current_command = "camera_right"
                }
            }
            
            if (
                Double(joystickData.angle) > Double.pi*5/4 &&
                    Double(joystickData.angle) < Double.pi*7/4
                )
            {
                if self.current_command != "camera_left" {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "camera_left", x: 0, y: 0))
                    self.mqttClient.subscribe("rpi/gpio")
                    self.mqttClient.didReceiveMessage = { mqtt, message, id in
                        print("Message received in topic \(message.topic) with payload \(message.string!)")
                    }
                    self.current_command = "camera_left"
                }
            }
            if Double(joystickData.angle) == 0 {
                if self.current_command != "camera_stop" {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "camera_stop", x: 0, y: 0))
                    self.current_command = "camera_stop"
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mqttClient.disconnect()
    }
    
    @IBAction func cameraReset(_ sender: Any) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "camera_forward", x: 0, y: 0))
        self.current_command = "camera_forward"
    }
}
