//
//  ViewController.swift
//  MQTTdemo
//
//  Created by YURY LVOV on 2019/08/12.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import UIKit
import CocoaMQTT
import CDJoystick
import WebKit

class ViewController: MqttConnectorController, UIWebViewDelegate {
    
    var current_speed = 0
    var engineStatus: Float = 0
    var stream_ip = ""
    var stream_port = ""
    var stream_uri = ""
    
    @IBOutlet weak var distanceTitlelable: UILabel!
    @IBOutlet weak var distanceItemLabel: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var manipulator: CDJoystick!
    @IBOutlet weak var cameraView: WKWebView!
    
    var current_command: String = "stop"
    var lights_status: Float = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func activateVideoStream() {
        // Load
        print(self.stream_uri)
        cameraView.load(URLRequest(url: URL(string: self.stream_uri )! as URL) as URLRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.stream_ip = defaults.string(forKey: "stream_ip") ?? "192.168.3.12"
        self.stream_port = defaults.string(forKey: "stream_port") ?? "8000"
        self.stream_uri = "http://" + self.stream_ip+":" + self.stream_port
        self.activateVideoStream()
        
        _ = self.mqttClient.connect()
        manipulator.trackingHandler = { joystickData in
            let y_speed = abs(Int(round(joystickData.velocity.y*10)))
            let x_speed = abs(Int(round(joystickData.velocity.x*10)))
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
                if self.current_command != "forward" || self.current_speed != y_speed {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "forward", x: x_speed, y: y_speed))
                    self.current_command = "forward"
                    self.current_speed = y_speed
                    
                    self.mqttClient.subscribe("rpi/gpio")
                    self.mqttClient.didReceiveMessage = { mqtt, message, id in
                        print("Message received in topic \(message.topic) with payload \(message.string!)")
                        self.displayTelemetry(message: message)
                    }
                }
            }
            
            if (
                Double(joystickData.angle) >= Double.pi*3/4 &&
                        Double(joystickData.angle) <= Double.pi*5/4
                )
            {
                if self.current_command != "back" || self.current_speed != y_speed {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "back", x: x_speed, y: y_speed))
                    self.current_command = "back"
                    self.current_speed = y_speed
                }
            }
            
            if (
                Double(joystickData.angle) > Double.pi*1/4 &&
                    Double(joystickData.angle) < Double.pi*3/4
                )
            {
                if self.current_command != "right" || self.current_speed != x_speed {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "right", x: x_speed, y: y_speed))
                    self.current_command = "right"
                    self.current_speed = x_speed
                }
            }
            
            if (
                Double(joystickData.angle) > Double.pi*5/4 &&
                    Double(joystickData.angle) < Double.pi*7/4
                )
            {
                if self.current_command != "left"  || self.current_speed != x_speed {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "left", x: x_speed, y: y_speed))
                    self.current_command = "left"
                    self.current_speed = x_speed
                }
            }
            
            if Double(joystickData.angle) == 0 {
                if self.current_command != "stop" {
                    self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "stop", x: x_speed, y: y_speed))
                    self.current_command = "stop"
                }
            }
        }
    }
    
    func displayTelemetry(message: CocoaMQTTMessage) {
        let json = String(bytes: message.payload, encoding: .utf8)!
        let decoder = JSONDecoder()
        do {
        let telemetry = try decoder.decode(TelemetryMessage.self, from: json.data(using: .utf8)!)
            print(telemetry.status)
            let current_data = telemetry.status
            if (current_data > 0) {
                self.distance.text = String(current_data)
            }
        } catch {
            print("Error receiving telemetry")
        }
    }
    
    @IBAction func switchEngingOnOff(_ sender: Any) {
        if engineStatus == 1 {
            engineStatus = 0
        } else {
            engineStatus = 1
        }
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "switch-motor-engine", x: 0, y: 0, status: engineStatus))
    }
    
    @IBAction func connectAction(_ sender: UIButton) {
        _ = self.mqttClient.connect()
    }
    
    @IBAction func toggleLight(_ sender: Any) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "toggle_light", x: 0, y: 0, status: lights_status))
        lights_status = lights_status == 1 ? 0 : 1
        self.current_command = "toggle_light"
    }
    
    @IBAction func activateRobotModeOne(_ sender: Any) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "robot_one", x: 0, y: 0, status: 0))
    }
    
    @IBAction func fullStop(_ sender: Any) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: "robot_mode_full_stop", x: 0, y: 0, status: 0))
    }
    
    @IBAction func disconnectAction(_ sender: UIButton) {
        self.mqttClient.disconnect()
    }
}

struct Message:Codable {
    let msg: String
    let x: Int
    let y: Int
    let status: Float
    let rightEngine: Int
    let leftEngine: Int
    let rightEngineBack: Int
    let leftEngineBack: Int
}

struct TelemetryMessage:Codable {
let msg: String
    let x: Float
    let y: Float
    let status: Int
}
