import SwiftUI
import FirebaseCore
import Firebase
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Función que se llama cuando la aplicación ha terminado de lanzarse
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Configura Firebase
        
        // Configurar notificaciones locales
        configureUserNotifications() // Llama a la función para configurar notificaciones de usuario
        
        return true // Retorna true indicando que la aplicación se lanzó correctamente
    }
    // Función para configurar las notificaciones de usuario
    func configureUserNotifications() {
        NotificationManager.shared.requestAuthorization() // Solicita autorización para enviar notificaciones
    }

    // Manejar la recepción de notificaciones en primer plano
    @available(iOS 10, *) // Indica que esta función está disponible en iOS 10 o superior
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // Muestra una alerta y reproduce un sonido cuando se recibe una notificación en primer plano
    }

    // Manejar la respuesta a notificaciones
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo // Obtiene la información de la notificación
        print(userInfo) // Imprime el mensaje completo
        completionHandler() // Llama al completador indicando que se ha manejado la notificación
    }
}

// Define la clase UserInterfaceMode que implementa ObservableObject para notificar cambios a las vistas
class UserInterfaceMode: ObservableObject {
    @Published var isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark // Publica la variable isDarkModeEnabled para notificar los cambios
}

@main // Anotación que indica el punto de entrada de la aplicación

// Define la estructura MyApp que conforma el protocolo App
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // Adapta AppDelegate para usarlo con SwiftUI
    @StateObject var userInterfaceMode = UserInterfaceMode() // Crea una instancia de UserInterfaceMode como un objeto de estado
    @StateObject var sessionStore = SessionStore() // Crea una instancia de SessionStore como un objeto de estado
    
    // Define el cuerpo de la escena de la aplicación
    var body: some Scene {
        // Define el grupo de ventanas para la aplicación
        WindowGroup {
            if sessionStore.isLoggedIn { // Comprueba si el usuario está autenticado
                MoviesView() // Muestra la vista de películas si el usuario está autenticado
                    .environmentObject(sessionStore) // Proporciona sessionStore como un objeto de entorno
                    .environmentObject(userInterfaceMode) // Proporciona userInterfaceMode como un objeto de entorno
                    .preferredColorScheme(userInterfaceMode.isDarkModeEnabled ? .dark : .light) // Establece el esquema de color preferido según el modo oscuro
                    .onAppear { // Ejecuta el código cuando la vista aparece
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { _ in // Añade un observador para los cambios en el marco del teclado
                            let isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark // Comprueba si el modo oscuro está habilitado
                            if isDarkModeEnabled != userInterfaceMode.isDarkModeEnabled { // Si el estado del modo oscuro ha cambiado
                                userInterfaceMode.isDarkModeEnabled = isDarkModeEnabled // Actualiza el estado del modo oscuro
                            }
                        }
                        sessionStore.listen() // Llama a la función listen de sessionStore para escuchar los cambios en el estado de autenticación
                    }
            } else {
                LoginView() // Muestra la vista de inicio de sesión si el usuario no está autenticado
                    .environmentObject(sessionStore) // Proporciona sessionStore como un objeto de entorno
                    .environmentObject(userInterfaceMode) // Proporciona userInterfaceMode como un objeto de entorno
                    .preferredColorScheme(userInterfaceMode.isDarkModeEnabled ? .dark : .light) // Establece el esquema de color preferido según el modo oscuro
                    .onAppear { // Ejecuta el código cuando la vista aparece
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { _ in // Añade un observador para los cambios en el marco del teclado
                            let isDarkModeEnabled = UIScreen.main.traitCollection.userInterfaceStyle == .dark // Comprueba si el modo oscuro está habilitado
                            if isDarkModeEnabled != userInterfaceMode.isDarkModeEnabled { // Si el estado del modo oscuro ha cambiado
                                userInterfaceMode.isDarkModeEnabled = isDarkModeEnabled // Actualiza el estado del modo oscuro
                            }
                        }
                        sessionStore.listen() // Llama a la función listen de sessionStore para escuchar los cambios en el estado de autenticación
                    }
            }
        }
    }
}

