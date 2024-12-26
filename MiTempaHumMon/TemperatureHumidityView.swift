import SwiftUI

struct TemperatureHumidityView: View {
    @ObservedObject private var bluetoothManager = CoreBluetoothManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Text("Connected Device Data")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            HStack(spacing: 40) {
                // Temperature Section
                VStack(spacing: 10) {
                    Image(systemName: "thermometer.sun")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                    
                    Text("Temperature")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(bluetoothManager.temperature)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }

                // Humidity Section
                VStack(spacing: 10) {
                    Image(systemName: "humidity.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Humidity")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(bluetoothManager.humidity)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            Spacer()

            Button("Disconnect") {
                bluetoothManager.disconnectAllDevices()
            }
            .foregroundColor(.white)
            .padding()
            .frame(width: 200)
            .background(Color.red)
            .cornerRadius(10)
        }
        .padding()
    }
}
