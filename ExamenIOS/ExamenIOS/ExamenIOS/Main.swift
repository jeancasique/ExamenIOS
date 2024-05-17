import SwiftUI
import FirebaseCore
import Firebase
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configurar notificaciones locales
        configureUserNotifications()
        
        return true
    }
    
    func configureUserNotifications() {
        NotificationManager.shared.requestAuthorization()
    }

    // Manejar la recepción de notificaciones en primer plano
    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // Manejar la respuesta a notificaciones
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo) // Print full message.
        completionHandler()
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
                        sessionStore.listen()
                    }
            }
        }
    }
}

