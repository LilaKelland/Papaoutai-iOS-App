//
//  ArduinoPeripheral.swift
//  Papaoutai
//
//  Created by Lila Kelland on 2021-02-04.
//
import UIKit
import CoreBluetooth

class ArduinoPeripheral: NSObject {

    /// MARK: - Particle LED services and charcteristics Identifiers

    
    public static let arduinoServiceUUID = CBUUID.init(string: "2EF7378E-E6A3-85B0-FC27-F82005E222B1")
    
    public static let batteryServiceUUID   = CBUUID.init(string: "180F")
    public static let batteryLevelCharUUID   = CBUUID.init(string: "2A19")
    
    public static let rssiCharacteristicUUID   = CBUUID.init(string: "2EF7378E-E6A3-85B0-FC27-F82005E222B1")

}

