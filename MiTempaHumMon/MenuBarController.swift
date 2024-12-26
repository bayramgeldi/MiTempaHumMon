import AppKit
import SwiftUI

class MenuBarController {
    private var statusBarItem: NSStatusItem?
    private var detailsWindow: NSWindow?

    init() {
        setupStatusBar()
    }

    private func setupStatusBar() {
        // Create a status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "thermometer", accessibilityDescription: "Temperature Monitor")
            button.action = nil // Remove button action since we're using a menu
        }

        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Details", action: #selector(showDetails), keyEquivalent: "d"))
        menu.addItem(NSMenuItem.separator()) // Add a separator
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        // Assign the menu to the status bar item
        statusBarItem?.menu = menu
    }

    // MARK: - Menu Actions

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "MiTempaHumMon"
        alert.informativeText = "Version 1.0\nMonitor temperature and humidity with ease."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func showDetails() {
        if detailsWindow == nil {
            let contentView = ContentView(menuBarController: self)
            detailsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            detailsWindow?.contentView = NSHostingView(rootView: contentView)
            detailsWindow?.title = "Details"
            detailsWindow?.center()
        }
        detailsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
