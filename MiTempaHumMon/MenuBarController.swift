import AppKit

class MenuBarController: ObservableObject {
    private var statusBarItem: NSStatusItem?

    init() {
        print("Initializing MenuBarController")
    }

    func setupStatusBar() {
        print("Setting up Menu Bar")
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusBarItem?.button else { return }
        button.image = NSImage(systemSymbolName: "thermometer", accessibilityDescription: "Temperature Monitor")

        let menu = NSMenu()
        
        let aboutItem = NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a")
        aboutItem.target = self // Explicitly set the target
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Disconnect Item
        let disconnectItem = NSMenuItem(title: "Disconnect", action: #selector(disconnectDevice), keyEquivalent: "d")
        disconnectItem.target = self
        menu.addItem(disconnectItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self // Explicitly set the target
        menu.addItem(quitItem)

        statusBarItem?.menu = menu
    }
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About Temperature and Humidity Monitor"
        alert.informativeText = """
        Author: Bayramgeldi Bayryyev
        License: MIT License

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func disconnectDevice() {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "This will disconnect all connected devices."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Yes") // First button (default)
        alert.addButton(withTitle: "Cancel") // Second button

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // User confirmed to disconnect
            CoreBluetoothManager.shared.disconnectAllDevices()
            
            let confirmationAlert = NSAlert()
            confirmationAlert.messageText = "Disconnected"
            confirmationAlert.informativeText = "All connected devices have been disconnected."
            confirmationAlert.alertStyle = .informational
            confirmationAlert.addButton(withTitle: "OK")
            confirmationAlert.runModal()
        } else {
            // User canceled the action
            print("Disconnect action canceled.")
        }
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}
