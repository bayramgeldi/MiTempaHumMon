import SwiftUI

struct ContentView: View {
    @ObservedObject private var bluetoothManager = CoreBluetoothManager.shared

    var body: some View {
        if bluetoothManager.isConnected {
            TemperatureHumidityView()
        }else{
            VStack {
                Text("Bluetooth Devices")
                    .font(.headline)
                    .padding()
                if bluetoothManager.centralState != .poweredOn {
                    Text("Please turn on Bluetooth")
                        .foregroundColor(.red)
                }
                else if bluetoothManager.discoveredDevicesCount==0 {
                    Text("No devices found")
                        .foregroundColor(.gray)
                } else {
                    Text("Discovered Devices:")
                    Text(String(bluetoothManager.discoveredDevicesCount))
                    List(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        HStack {
                            Text(device.name ?? "Unknown Device")
                            Spacer()
                            Button("Connect") {
                                bluetoothManager.connectToDevice(device)
                            }
                        }
                    }
                }
            }
            .onAppear {
                bluetoothManager.startScanning()
            }
        }
    }
}
