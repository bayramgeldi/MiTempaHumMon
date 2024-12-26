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
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusBarItem?.menu = menu
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MiTempaHumMon"
        alert.informativeText = "Version 1.0"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
