//
//  Device.swift
//  Mac-Bluetooth-iOS
//
//  Created by Ramneet on 03/05/20.
//  Copyright © 2020 Ramneet. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Device {
    
    var peripheral : CBPeripheral
    var name : String
    var messages = Array<String>()
    var state : Bool = false
    
    init(peripheral: CBPeripheral, name:String) {
        self.peripheral = peripheral
        self.name = name
    }
}
