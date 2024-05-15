import SwiftUI
import FirebaseCore
import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

class UserInterfaceMode: ObservableObject {
    @Published var isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userInterfaceMode = UserInterfaceMode()
    @StateObject var sessionStore = SessionStore()

    var body: some Scene {
        WindowGroup {
            if sessionStore.isLoggedIn {
                MoviesView()
                    .environmentObject(sessionStore)
                    .environmentObject(userInterfaceMode)
                    .preferredColorScheme(userInterfaceMode.isDarkModeEnabled ? .dark : .light)
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { _ in
                            let isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark
                            if isDarkModeEnabled != userInterfaceMode.isDarkModeEnabled {
                                userInterfaceMode.isDarkModeEnabled = isDarkModeEnabled
                            }
                        }
                    }
                    .onAppear {
                        sessionStore.listen()
                    }
            } else {
                LoginView()
                    .environmentObject(sessionStore)
                    .environmentObject(userInterfaceMode)
                    .preferredColorScheme(userInterfaceMode.isDarkModeEnabled ? .dark : .light)
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { _ in
                            let isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark
                            if isDarkModeEnabled != userInterfaceMode.isDarkModeEnabled {
                                userInterfaceMode.isDarkModeEnabled = isDarkModeEnabled
                            }
                        }
                    }
                    .onAppear {
                        sessionStore.listen()
                    }
            }
        }
    }
}

