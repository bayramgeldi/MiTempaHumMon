//
//  CoreBluetoothManager.swift
//  MiTempaHumMon
//
//  Created by bayramgeldi on 26.12.2024.
//

import Foundation
import CoreBluetooth

class CoreBluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    static let shared = CoreBluetoothManager(menuBarController: MenuBarController())

    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var discoveredDevicesCount: Int = 0
    @Published var centralState: CBManagerState = .unknown
    @Published var isConnected: Bool = false
    @Published var temperature: String = "N/A"
    @Published var humidity: String = "N/A"

    var centralManager: CBCentralManager!
    let serviceMi = CBUUID(string: "ebe0ccb0-7a0a-4b0c-8a1a-6ff2997da3a6")
    let characteristicSpeed = CBUUID(string: "ebe0ccd8-7a0a-4b0c-8a1a-6ff2997da3a6")
    let characteristicTemp = CBUUID(string: "ebe0ccc1-7a0a-4b0c-8a1a-6ff2997da3a6")

    private var menuBarController: MenuBarController

    init(menuBarController: MenuBarController) {
        self.menuBarController = menuBarController
        super.init()
        print("Initializing CoreBluetoothManager")
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.centralState = central.state
        }
        print("Central Manager state updated to: \(central.state.rawValue)")

        if central.state == .poweredOn {
            print("Central Manager is powered on. Starting scanning.")
            startScanning()
        } else {
            print("Central Manager is not ready. Current state: \(central.state.rawValue)")
            if central.state == .poweredOff {
                DispatchQueue.main.async {
                    self.discoveredDevices.removeAll()
                    self.discoveredDevicesCount = 0
                }
            }
        }
    }
    
    func startScanning() {
        print("Attempting to start scanning...")
        guard let centralManager = centralManager, centralManager.state == .poweredOn else {
            print("Cannot start scanning. Central Manager is not powered on.")
            return
        }

        DispatchQueue.main.async {
            self.discoveredDevices.removeAll()
            self.discoveredDevicesCount = 0
        }

        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        print("Started scanning for peripherals.")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered device: \(peripheral.name ?? "Unknown") - RSSI: \(RSSI)")
        
        DispatchQueue.main.async {
            self.discoveredDevicesCount += 1
            if let name = peripheral.name, name.hasPrefix("LYWS"),
               !self.discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                self.discoveredDevices.append(peripheral)
                print("Added device: \(name)")
            }
        }
    }
    
    func connectToDevice(_ peripheral: CBPeripheral) {
        guard centralManager.state == .poweredOn else { return }
        centralManager.stopScan()
        print("Connecting to \(peripheral.name ?? "Unknown"))")
        centralManager.connect(peripheral, options: nil)
    }
    
    func connectToDeviceByIdentifier(_ id: UUID) {
        if let device = discoveredDevices.first(where: { $0.identifier == id }) {
            connectToDevice(device)
        } else {
            print("Device with UUID \(id) not found.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        DispatchQueue.main.async {
            print("Connected to \(peripheral.name ?? "Unknown"))")
            self.isConnected = true
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil { return }
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == serviceMi {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil { return }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.uuid == characteristicTemp {
                // Enable notifications for temperature and humidity characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil { return }
        guard let data = characteristic.value else { return }
        
        // Handle Temperature and Humidity Data
        if characteristic.uuid == characteristicTemp {
            if data.count >= 3 {
                let tempSign = (data[1] & 0x80) != 0 // Check if the sign bit is set
                var temp = ((Int(data[1] & 0x7F) << 8) | Int(data[0])) // Combine bytes
                if tempSign { temp -= 32768 } // Adjust for negative temperatures
                let humidityValue = Int(data[2])
                let temperatureValue = Double(temp) / 100.0
                print("Temperature: \(temperatureValue), Humidity: \(humidityValue)")
                DispatchQueue.main.async {
                    self.temperature = String(format: "%.2f°C", temperatureValue)
                    self.humidity = "\(humidityValue)%"
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {}
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }
    
    func disconnectAllDevices() {
        print("Disconnecting all devices...")
        discoveredDevices.forEach { peripheral in
            print("Disconnecting \(peripheral.name ?? "")")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
}
