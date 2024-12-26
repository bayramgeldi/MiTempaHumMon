import SwiftUI

@main
struct MiTempaHumMonApp: App {
    private let menuBarController = MenuBarController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    menuBarController.setupStatusBar()
                }
        }
    }
}
