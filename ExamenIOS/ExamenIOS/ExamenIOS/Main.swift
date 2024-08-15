import SwiftUI
import FirebaseCore
import Firebase
import UIKit
import UserNotifications
import FacebookCore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        configureUserNotifications()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

    func configureUserNotifications() {
        NotificationManager.shared.requestAuthorization()
    }

    @available(iOS 10, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
}

class UserInterfaceMode: ObservableObject {
    @Published var isDarkModeEnabled = true // Modo oscuro por defecto
}

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userInterfaceMode = UserInterfaceMode()
    @StateObject var sessionStore = SessionStore()
    @StateObject var perfilViewModel = PerfilViewModel(userData: UserData()) // Asegúrate de que este inicializador es válido

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionStore)
                .environmentObject(userInterfaceMode)
                .environmentObject(perfilViewModel) // Asegúrate de que estás usando .environmentObject correctamente
                .preferredColorScheme(.dark) // Establece el modo oscuro por defecto
                .onAppear {
                    sessionStore.listen()
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if session.isLoggedIn {
                MoviesView()
            } else {
                LoginView()
            }
        }
    }
}

