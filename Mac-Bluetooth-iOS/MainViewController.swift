//
//  ViewController.swift
//  Mac-Bluetooth-iOS
//
//  Created by Ramneet on 03/05/20.
//  Copyright © 2020 Ramneet. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController {

    var name = ""
    var visibleDevices = Array<Device>()
    var cachedDevices = Array<Device>()
    var devicesList = Array<Device>()
    var cachedPeripheralNames = Dictionary<String, String>()
    var timer = Timer()
    
    var peripheralManager = CBPeripheralManager()
    var centralManager: CBCentralManager?
    var selectedPeripheral : CBPeripheral?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var receivedLbl: UILabel!
    @IBOutlet weak var lblConnected: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        
        self.hideKeyboardWhenTappedAround()
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        scheduledTimerWithTimeInterval()
        // Do any additional setup after loading the view.
    }

    
   // Buttons Actions
    @IBAction func sendAction(_ sender: Any) {
        
        //centralManager?.connect(selectedPeripheral!, options: nil)
        selectedPeripheral?.delegate = self
        selectedPeripheral?.discoverServices(nil)
    }
    
    @IBAction func disconnectAction(_ sender: UIButton) {
        
        if selectedPeripheral != nil{
          centralManager?.cancelPeripheralConnection(selectedPeripheral!)
        }
    }
    
    func scheduledTimerWithTimeInterval(){
        
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(self.clearPeripherals), userInfo: nil, repeats: true)
    }
    @objc
    func clearPeripherals(){
        
        visibleDevices = cachedDevices
        cachedDevices.removeAll()
        tableView.reloadData()
    }

    func updateAdvertisingData() {
          
          if (peripheralManager.isAdvertising) {
              peripheralManager.stopAdvertising()
          }
          
//          let userData = UserData()
//          let advertisementData = String(format: "%@|%d|%d", userData.name, userData.avatarId, userData.colorId)
          
          peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey: name])
      }
    
    func addOrUpdatePeripheralList(device: Device) {

        if !cachedDevices.contains(where: { $0.peripheral.identifier == device.peripheral.identifier }) {
            
            cachedDevices.append(device)
            
        }
        else if cachedDevices.contains(where: { $0.peripheral.identifier == device.peripheral.identifier
        && $0.name == "unknown"}) && device.peripheral.name != "unknown" && device.peripheral.name != nil {

            for index in 0..<cachedDevices.count {

                if (cachedDevices[index].peripheral.identifier == device.peripheral.identifier) {

                    cachedDevices[index].name = device.peripheral.name ?? "nill"
                    cachedDevices[index].state = false
                    //clearPeripherals(
                    //tableView.reloadData()
                    break
                }
            }

        }
    }
    
    func initService() {
        
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        let rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: Constants.RX_PROPERTIES, value: nil, permissions: Constants.RX_PERMISSIONS)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
    
}


extension MainViewController : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            
            initService()
            updateAdvertisingData()
        }
    }
    
        
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
            for service in peripheral.services! {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,error: Error?) {
            
            for characteristic in service.characteristics! {
                
                let characteristic = characteristic as CBCharacteristic
                if (characteristic.uuid.isEqual(Constants.RX_UUID)) {
                    if let messageText = messageTextField.text {
                        let data = messageText.data(using: .utf8)
                        peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                        messageTextField.text = ""
                        
                    }
                }
                
            }
        }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
           
           for request in requests {
               if let value = request.value {
                   
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                    receivedLbl.text = messageText
               }
               self.peripheralManager.respond(to: request, withResult: .success)
           }
       }
    
}

extension MainViewController : CBCentralManagerDelegate , CBPeripheralDelegate{
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
           
//           peripheral.delegate = self
//           peripheral.discoverServices(nil)
        if central.isScanning{
            
            selectedPeripheral = peripheral
        }
        
        lblConnected.text = "Connected with \(peripheral.name ?? "")"
        selectedPeripheral = peripheral
       }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        lblConnected.text = "Disconnected with \(peripheral.name ?? "")"
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            
            self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("*********didDiscover")
        var peripheralName = cachedPeripheralNames[peripheral.identifier.description] ?? "unknown"
        
        if let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            peripheralName = advertisementName
            cachedPeripheralNames[peripheral.identifier.description] = peripheralName
        }
        
        let device = Device(peripheral: peripheral, name: peripheralName)
        print(device)
        self.addOrUpdatePeripheralList(device: device)
        //self.addOrUpdatePeripheralList(device: device, list: &cachedDevices)

        
    }
}




extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return visibleDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cellClassTableViewCell
        
        cell.name_lbl.text = "\(visibleDevices[indexPath.row].name)"
        
        if visibleDevices[indexPath.row].state {
        cell.deviceStateLbl.text = "Connected"
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedPeripheral = visibleDevices[indexPath.row].peripheral
        
         centralManager?.connect(selectedPeripheral!, options: nil)
    }
    
}



// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
