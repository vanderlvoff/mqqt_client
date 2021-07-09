//
//  SonicViewController.swift
//  MQTTdemo
//
//  Created by YURY LVOV on 2019/11/13.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import CDJoystick

class SonicViewController: MqttConnectorController {
    
    @IBOutlet weak var sonicJoystick: CDJoystick!
    var current_command: String = "stop"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = self.mqttClient.connect()
        self.sonicJoystick.trackingHandler = { joystickData in

            let y_speed = Int(round(joystickData.velocity.y*10))
            let x_speed = Int(round(joystickData.velocity.y*10))
            if (
                Double(joystickData.angle) > Double.pi*7/4 &&
                Double(joystickData.angle) <= Double.pi*2
                )
                ||
                (
                    Double(joystickData.angle) < Double.pi*1/4 &&
                    Double(joystickData.angle) >= 0
                )
            {
                if self.current_command != "sonic_up" {
                    self.publish(msg: "sonic_up", x_speed: x_speed, y_speed: y_speed)
                    self.current_command = "_sonic_up"
                }
            }
            
            if (
                Double(joystickData.angle) >= Double.pi*3/4 &&
                        Double(joystickData.angle) <= Double.pi*5/4
                )
            {
                if self.current_command != "sonic_down" {
                    self.publish(msg: "sonic_down", x_speed: x_speed, y_speed: y_speed)
                    self.current_command = "_sonic_down"
                }
            }
            
            if (
                Double(joystickData.angle) > Double.pi*1/4 &&
                    Double(joystickData.angle) < Double.pi*3/4
                )
            {
                if self.current_command != "sonic_right" {
                    self.publish(msg: "sonic_right", x_speed: x_speed, y_speed: y_speed)
                    self.current_command = "_sonic_right"
                }
            }
            
            if (
                Double(joystickData.angle) > Double.pi*5/4 &&
                    Double(joystickData.angle) < Double.pi*7/4
                )
            {
                if self.current_command != "sonic_left" {
                    self.publish(msg: "sonic_left", x_speed: x_speed, y_speed: y_speed)
                    self.current_command = "_sonic_left"
                }
            }
            
            if Double(joystickData.angle) == 0 {
                if self.current_command != "sonic_stop" {
                    self.publish(msg: "sonic_stop", x_speed: x_speed, y_speed: y_speed)
                    self.current_command = "_sonic_stop"
                }
            }
        }
    }
    
    @IBAction func alignUltraSonics(_ sender: Any) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "ultrasonic_align", x: 0, y: 0))
        self.current_command = "ultrasonic_align"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.mqttClient.disconnect()
    }
}
