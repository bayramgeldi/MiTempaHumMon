import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @ObservedObject private var bluetoothManager = CoreBluetoothManager.shared
    @State private var recentSensors: [PeripheralInfo] = [] // State to store recent sensors

    var body: some View {
        if bluetoothManager.isConnected {
            TemperatureHumidityView()
        } else {
            VStack {
                Text("Bluetooth Devices")
                    .font(.headline)
                    .padding()
                Text("currently only compatible with Mi Temperature and Humidity Monitor 2 (LYWSD03MMC)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
                
                if bluetoothManager.centralState != .poweredOn {
                    Text("Please turn on Bluetooth")
                        .foregroundColor(.red)
                } else if bluetoothManager.discoveredDevicesCount == 0 {
                    Text("No devices found")
                        .foregroundColor(.gray)
                } else {
                    Text("Discovered Devices:")
                    Text(String(bluetoothManager.discoveredDevicesCount))
                    List(Array(bluetoothManager.discoveredDevices.enumerated()), id: \.1.identifier) { index, device in
                        HStack {
                            Text(device.name ?? "Unknown Device")
                            Spacer()
                            Text(device.identifier.uuidString.suffix(4))
                            Spacer()
                            Button("Connect") {
                                bluetoothManager.connectToDevice(device)
                                addToRecentSensors(device) // Add device to recent sensors
                            }
                        }
                        .padding()
                        .background(index % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear) // Alternating background colors
                        .cornerRadius(10) // Rounded corners
                    }
                }

                // Recent Sensors Section
                if !recentSensors.isEmpty {
                    Text("Recent Sensors")
                        .padding(.top, 10)
                    List(Array(recentSensors.enumerated()), id: \.1.id) { index, sensor in
                        HStack {
                            Text(sensor.name ?? "Unknown Device")
                            Spacer()
                            Text(sensor.id.uuidString.suffix(4))
                            Spacer()
                            Button("Reconnect") {
                                bluetoothManager.connectToDeviceByIdentifier(sensor.id)
                            }
                        }
                        .padding()
                        .background(index % 2 == 0 ? Color.gray.opacity(0.2) : Color.clear) // Alternating background colors
                        .cornerRadius(10) // Rounded corners
                    }
                }
            }
            .onAppear {
                bluetoothManager.startScanning()
                loadRecentSensors()
            }
        }
    }

    // Add device to recent sensors
    private func addToRecentSensors(_ device: CBPeripheral) {
        let newSensor = PeripheralInfo(id: device.identifier, name: device.name)
        if !recentSensors.contains(where: { $0.id == device.identifier }) {
            recentSensors.append(newSensor)
            saveRecentSensors()
        }
    }

    // Save recent sensors to UserDefaults
    private func saveRecentSensors() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(recentSensors) {
            UserDefaults.standard.set(encoded, forKey: "recentSensors")
        }
    }

    // Load recent sensors from UserDefaults
    private func loadRecentSensors() {
        if let data = UserDefaults.standard.data(forKey: "recentSensors") {
            let decoder = JSONDecoder()
            if let savedSensors = try? decoder.decode([PeripheralInfo].self, from: data) {
                recentSensors = savedSensors
            }
        }
    }
}

// Helper struct to store peripheral info
struct PeripheralInfo: Codable, Hashable {
    let id: UUID
    let name: String?
}
