import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager: CoreBluetoothManager
    private var menuBarController: MenuBarController

    init(menuBarController: MenuBarController) {
        _bluetoothManager = StateObject(wrappedValue: CoreBluetoothManager(menuBarController: menuBarController))
        self.menuBarController = menuBarController
    }

    var body: some View {
        VStack {
            Text("Bluetooth Devices")
                .font(.headline)
                .padding()

            if bluetoothManager.centralState != .poweredOn {
                Text("Please turn on Bluetooth")
                    .foregroundColor(.red)
            } else {
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

            Spacer()

            if bluetoothManager.isConnected {
                Text("Temperature: \(bluetoothManager.temperature)")
                Text("Humidity: \(bluetoothManager.humidity)")
            }
        }
        .onAppear {
            bluetoothManager.startScanning()
        }
    }
}
