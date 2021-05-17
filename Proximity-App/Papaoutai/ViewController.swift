//
//  ViewController.swift
//  Papaoutai
//  references:
//      https://www.novelbits.io/intro-ble-mobile-development-ios/
//      https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor#toc-anchor-007
//      https://www.linkedin.com/learning/ios-core-bluetooth-for-developers/reading-a-characteristic-value
//  Created by Lila Kelland on 2021-02-01.

// Need to slow down time between scans
// Also, should iphone never connect with device and use available rssi() when scanning - send data every set interval always and do processing on backend?

import UIKit
import CoreBluetooth
import SwiftUI
import Alamofire
import SwiftyJSON

//struct Session: Decodable {
//    var id: Int = 99
//    var startTime: Int
//    var duration: Int
//}

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var timer = Timer()
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral!

    let arduinoServiceUUID = CBUUID.init(string: "2EF7378E-E6A3-85B0-FC27-F82005E222B1")
    let rssiCharUUID = CBUUID.init(string: "4170bbdd-8b46-48ab-9189-0bda5a295589")
    let RSSIMaxLimit = -40
    
    var startTime: Double = Date().timeIntervalSince1970
    var bathroomTimePassed: Double = 0
    var count: Int = 0
    
    @IBOutlet weak var rssiLabel: UILabel!

    @IBOutlet weak var totalTime: UILabel!
    
    @IBOutlet weak var launchButton: UIButton!
    @IBAction func launchStats(_ sender: UIButton) {
        do {
            try launchStatsPage()
        }catch {
            print("error \(error)")
        }
        print("button was presssed - webpage should be launching")
    }
    
    // is bluetooth on/ start scanning
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
            print("scanning for arduino")
            central.scanForPeripherals(withServices: [arduinoServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
       } else {
            print("Something wrong with BLE")
        }
    }

    // discover specific peripheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Still scanning...")
        if let pname = peripheral.name {
        
            if pname == "Nano" {
                print ("yay found arduino - checking distance...")
                guard ((RSSI.intValue > RSSIMaxLimit) && (RSSI.intValue < 0))
                    else {
                    print("arduino too far, at  \(RSSI.intValue)")
                    return
                }
                getStartTime()

                print("rssi in! :\(RSSI.intValue)")
                centralManager.stopScan()
                rssiLabel.text = RSSI.stringValue
                arduinoPeripheral = peripheral
                arduinoPeripheral.delegate = self
                centralManager.connect(arduinoPeripheral)
            }
        }
    }
    
    //Did connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == self.arduinoPeripheral {
            print("Connected for Reals! to \(String(describing: peripheral.name))")
            peripheral.discoverServices([arduinoServiceUUID])
            peripheral.delegate = self
        }
    }
    
    // found service - discover characteristcis
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            print("services \(services)")
            for service in services {
                if service.uuid == arduinoServiceUUID {
                    print("arduino service found")
                    peripheral.discoverCharacteristics(nil, for: service)
                    print("discovering characteristics...")
                    return
                }
            }
        }
    }
    
    // Handling discovery of characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("found one: ")
                print(characteristic.uuid.uuidString)
               
                if characteristic.uuid == rssiCharUUID {
                    print("rssi characteristic found")
                    checkRssiValue(curChar: characteristic)
                } else {
                    print("Couldn't find RSSI characteristic")
                    centralManager.cancelPeripheralConnection(peripheral)
                }
            }
        }
    }
    
    func checkRssiValue(curChar : CBCharacteristic) {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in self.arduinoPeripheral?.readValue(for: curChar)
        }
    }
 
//    get value
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.value != nil {
            if characteristic.uuid == rssiCharUUID {

                let rssiValue = rssiConvert(from: characteristic)
                print (rssiValue)
                rssiLabel.textColor = .systemIndigo
                rssiLabel.text = String(rssiValue)
                totalTime.textColor = .systemIndigo
                convertTimeIntervalToDisplay()
                
                if rssiValue > abs(RSSIMaxLimit) {
                    if count == 0 { // to discount outlier faulty readings
                        count = 1
                        print("count = \(count)")
                    } else {
                        count = 0
                        print("\(rssiValue) is too far, disconnecting")

                        centralManager.cancelPeripheralConnection(peripheral)
                    }
                }
                
            } else {
                print("something going on with characteristics - disconnecting")
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }
        
//    on disconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.arduinoPeripheral {
            do {
                try logTime()
                print("just tried to log")
            } catch let error {
                print(error)
            }
            
            totalTime.text = "00:00:00"
            rssiLabel.textColor = UIColor(white: 1, alpha: 1)
            totalTime.textColor = UIColor(white: 1, alpha: 1)
            print("Disconnected")
            self.arduinoPeripheral = nil
            print("Central scanning for", ArduinoPeripheral.arduinoServiceUUID);
            centralManager.scanForPeripherals(withServices: [ArduinoPeripheral.arduinoServiceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    
    private func rssiConvert (from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        return Int(byteArray[0])
    }
    
    func getStartTime() {
        let now = Date()
        self.startTime = now.timeIntervalSince1970
        print("start time \(startTime)")
    }
    
    func logTime() throws  {
//        let user_id = String(123)
//        let start_time = String(self.startTime)
//        let duration = String(self.bathroomTimePassed)
        let parameters = [
            "user_id": String(123),
            "startTime": String(self.startTime),
            "duration": String(self.bathroomTimePassed)
            ]
        print(parameters)
//        print(headers)
//        APIFunctions.functions.addSession(
//        "http://192.168.4.29:5000/add" for node server
        AF.request("https://papaoutai-rest-api.herokuapp.com/Session", method: .post, parameters: parameters)
           .validate()
          .responseString {
            response in
               switch response.result {
                   case .success( _):
                       print("time sent to server - sucess!")
                   case .failure(let error):
                       print(error)
                }
            }
    }
    
    func launchStatsPage() throws  {
        let parameters = [
            "user_id": 123
            ]
        print(parameters)
        AF.request("\(Environment.url_string)/launchStatsPage", method: .get, parameters: parameters)
           .validate()
          .responseString {
            response in
               switch response.result {
                   case .success( _):
                       print("user_id sent to server - sucess!")
//                    TODO - actually launch webpage
                   case .failure(let error):
                       print("error: \(error)")
                }
            }
    }
    
    func convertTimeIntervalToDisplay(){
        self.bathroomTimePassed = Date().timeIntervalSince1970 - self.startTime
      
        let hours = Int(floor(self.bathroomTimePassed/3600))
        let minutes = Int(floor(self.bathroomTimePassed/60))
        let seconds = Int(round(self.bathroomTimePassed - Double(minutes * 60)))
        
        totalTime.text = (String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        launchButton.backgroundColor = .systemGray3
        launchButton.layer.cornerRadius = launchButton.frame.height / 6
        launchButton.layer.shadowOpacity = 0.25
        launchButton.layer.shadowRadius = 5
        launchButton.layer.shadowOffset = CGSize(width: 0, height: 5)
    }


}

