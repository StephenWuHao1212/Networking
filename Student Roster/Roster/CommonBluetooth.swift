//
//  CommonBluetooth.swift
//  Roster
//
//  Created by Deyu Jiao on 10/4/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit
import CoreBluetooth

let SERVICE_UUID = "973A007E-3C39-45C6-B2DD-0141DD82F973"
let CHARACTERISTIC_UUID = "1D04E43A-4B06-41D9-A499-7594D94A7814"
let MTU = 20
let serviceUUIDs:[AnyObject] = [CBUUID(string: SERVICE_UUID)]
let serviceUUID = CBUUID(string: SERVICE_UUID)
let characteristicUUIDs:[AnyObject] = [CHARACTERISTIC_UUID]
let characteristicUUID = CBUUID(string: CHARACTERISTIC_UUID)
let endOfMessage = "EOM".dataUsingEncoding(NSUTF8StringEncoding)
let stopInMiddle = "SIM".dataUsingEncoding(NSUTF8StringEncoding)