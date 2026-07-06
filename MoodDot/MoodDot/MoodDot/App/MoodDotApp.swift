import SwiftUI

@main
struct MoodDotApp: App {
    @State private var goMain = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if goMain {
                    RootTabView()
                } else {
                    SplashView(goMain: $goMain)
                }
            }
        }
    }
}
