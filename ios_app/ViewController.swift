//
//  ViewController.swift
//  Papaoutai
//references: https://www.novelbits.io/intro-ble-mobile-development-ios/
//https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor#toc-anchor-007
//https://www.linkedin.com/learning/ios-core-bluetooth-for-developers/reading-a-characteristic-value
//  Created by Lila Kelland on 2021-02-01.
//

// Need to slow down time between scans

import UIKit
import CoreBluetooth
import SwiftUI
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var timer = Timer()
//    var startTime =
    var centralManager: CBCentralManager!
    var arduinoPeripheral: CBPeripheral!

    let arduinoServiceUUID = CBUUID.init(string: "2EF7378E-E6A3-85B0-FC27-F82005E222B1")
    let rssiCharUUID = CBUUID.init(string: "4170bbdd-8b46-48ab-9189-0bda5a295589")
    let RSSIMaxLimit = -40
    var timeStart = Date().timeIntervalSince1970
    var bathroomTimePassed: Double = 0.0
    var count: Int = 0
    
    @IBOutlet weak var rssiLabel: UILabel!

    @IBOutlet weak var totalTime: UILabel!
    
    

//    let dateFormatter = DateFormatter();
//    dateFormatter.dateFormat = "yyy-MM-dd hh:mm:ss"
//
//        let date = dateFormatter.string(from: Date())
//
//        self.totalTime.text = date

//    func runUpdates() {
//         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateDisplay)), userInfo: nil, repeats: true)
//    }
//
//
//    @objc func updateDisplay() {
//
////            update feilds with time and rssi
//    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        updates when bluetooth periheral is turned on or off / start scanning
        print("Central state update")
        if central.state == CBManagerState.poweredOn {
            print("BLE powered on")
            print("scanning for arduino")
            central.scanForPeripherals(withServices: [arduinoServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        } else {
            print("Something wrong with BLE")
        }
    }
    
    func getStartTime() {
        let now = Date()
        self.timeStart = now.timeIntervalSince1970
        print("start time \(timeStart)")
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm:ss"
//        dateFormatter.timeZone = TimeZone(abbreviation: "AST")
//        let convertedDateTime = dateFormatter.string(from: now)
//        print(convertedDateTime)
////                convertedDate = dateFormatter.stringFromDate(currentDate)
    }
    
    func convertTimeIntervalToDisplay(){
        self.bathroomTimePassed = Date().timeIntervalSince1970 - self.timeStart
      
        let hours = Int(floor(self.bathroomTimePassed/3600))
        let minutes = Int(floor(self.bathroomTimePassed/60))
        let seconds = Int(round(self.bathroomTimePassed - Double(minutes * 60)))
        
        totalTime.text = (String(format: "%02d:%02d:%02d", hours, minutes, seconds))
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Still scanning...")
        if let pname = peripheral.name {
        
            if pname == "Nano" {
                print ("yay found Nano - checking distance...")
                guard ((RSSI.intValue > RSSIMaxLimit) && (RSSI.intValue < 0))
                    else {
                    print("Discovered perhiperal too far, at  \(RSSI.intValue)")
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
        
       // if let val = characteristic.value {
            if characteristic.uuid == rssiCharUUID {

                let rssiValue = rssiConvert(from: characteristic)
                print (rssiValue)
                rssiLabel.text = String(rssiValue)
                convertTimeIntervalToDisplay()
                
                if rssiValue > abs(RSSIMaxLimit) {
                    if count == 0 { // to discount outlier faulty readings
                        count = 1
                        print("count = \(count)")
                    } else {
                        count = 0
                        print("\(rssiValue) is too far, disconnecting")
                        do {
                            try logTime()
                            print("just tried to log")
                        } catch let error {
                            print(error)
                        }
                        centralManager.cancelPeripheralConnection(peripheral)
                    }
               // }
                
            } else {
                print("something going on with characteristics - disconnecting")
                centralManager.cancelPeripheralConnection(peripheral)
            }
        }
    }
    
    private func rssiConvert (from characteristic: CBCharacteristic) -> Int {
      guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        return Int(byteArray[0])
    }

    
    func logTime() throws  {
        let parameters = [
//            "user_id": token?,
            "startTime": self.timeStart,
            "elapsedTime": self.bathroomTimePassed
            ]
        print(parameters)
        AF.request("\(Environment.url_string)/addSession", method: .get, parameters: parameters)
           .validate()
          .responseString {
            response in
               switch response.result {
                   case .success( _):
                       print("parameters set on server - sucess!")
//                       self.finishSetLoad = true
                   case .failure(let error):
//                        self.finishSetLoad = false
                       print(error)
                }
            }
    }

    
//    on disconnect
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.arduinoPeripheral {
            print("Disconnected")
            self.arduinoPeripheral = nil
            print("Central scanning for", ArduinoPeripheral.arduinoServiceUUID);
            centralManager.scanForPeripherals(withServices: [ArduinoPeripheral.arduinoServiceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        runUpdates()
    }


}

