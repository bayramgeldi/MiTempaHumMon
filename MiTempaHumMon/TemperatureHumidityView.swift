import SwiftUI

struct TemperatureHumidityView: View {
    @ObservedObject var bluetoothManager: CoreBluetoothManager
    var menuBarController: MenuBarController

    var body: some View {
        if !bluetoothManager.isConnected {
            // Navigate back to the main view when disconnected
            ContentView(menuBarController: menuBarController)
        } else {
            VStack {
                Text("Connected Device Data")
                    .font(.title2)
                    .padding()

                Text("Temperature: \(bluetoothManager.temperature)")
                    .font(.headline)
                    .padding()

                Text("Humidity: \(bluetoothManager.humidity)")
                    .font(.headline)
                    .padding()

                Spacer()

                Button("Disconnect") {
                    bluetoothManager.disconnectAllDevices()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}
