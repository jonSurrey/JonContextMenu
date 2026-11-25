import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                UIKitExampleView()
                    .ignoresSafeArea()
                    .tabItem { Label("UIKit", systemImage: "list.bullet") }
                SwiftUIExampleView()
                    .tabItem { Label("SwiftUI", systemImage: "square.grid.2x2") }
            }
        }
    }
}
