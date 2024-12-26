import SwiftUI
import AppKit

@main
struct MiTempaHumMonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(menuBarController: appDelegate.menuBarController!)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarController: MenuBarController?
    private var bluetoothManager: CoreBluetoothManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the Menu Bar Controller
        menuBarController = MenuBarController()

        // Initialize the CoreBluetoothManager
        if let menuBarController = menuBarController {
            bluetoothManager = CoreBluetoothManager(menuBarController: menuBarController)
        }
    }
}
