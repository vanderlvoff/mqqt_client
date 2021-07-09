//
//  MqttConnectorController.swift
//  MQTTdemo
//
//  Created by YURY LVOV on 2019/11/13.
//  Copyright © 2019 YURY LVOV. All rights reserved.
//

import Foundation
import CocoaMQTT

class MqttConnectorController: UIViewController, CocoaMQTTDelegate
{
    var mqttClient = CocoaMQTT(clientID: "iOS Device", host: "192.168.4.1", port: 1883)
    var left_engine = 0
    var right_engine = 0
    var left_engine_back = 0
    var right_engine_back = 0
    var host = "192.168.1.5"
    let defaults = UserDefaults.standard
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        self.host = defaults.string(forKey: "rpi_ip") ?? "192.168.1.5"
        self.mqttClient = CocoaMQTT(clientID: "iOS Device", host: self.host, port: 1883)
        self.mqttClient.delegate = self
        _ = self.mqttClient.connect()
        self.mqttClient.subscribe("rpi/gpio")
        self.left_engine = defaults.integer(forKey: "left_engine")
        self.right_engine = defaults.integer(forKey: "right_engine")
        self.left_engine_back = defaults.integer(forKey: "left_engine_back")
        self.right_engine_back = defaults.integer(forKey: "right_engine_back")
    }
    
    func publish(msg: String, x_speed: Int, y_speed: Int) {
        self.mqttClient.publish("rpi/gpio", withString: self.prepareMessage(msg: msg, x: x_speed, y: y_speed))
    }
    
    func prepareMessage(msg: String, x: Int, y: Int, status: Float = 0) -> String {
        let message: Message = Message(msg: msg, x: x, y: y, status: status, rightEngine: self.right_engine, leftEngine: self.left_engine, rightEngineBack: self.right_engine_back, leftEngineBack: self.left_engine_back)
        var jsonstr:String = ""
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(message)
            jsonstr = String(data: data, encoding: .utf8)!
        } catch {
            print("failed")             
            print(error.localizedDescription)
        }
        return jsonstr
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Connected")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("Disconnect")
    }
}
