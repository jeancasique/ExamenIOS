import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager() // Crea una instancia estática compartida de NotificationManager
    
    private override init() { // Inicializador privado para asegurar que solo haya una instancia de NotificationManager
        super.init() // Llama al inicializador de la superclase
        UNUserNotificationCenter.current().delegate = self // Asigna el delegado del centro de notificaciones a esta instancia
    }
    // Función para solicitar autorización para enviar notificaciones
    func requestAuthorization() {
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge] // Define las opciones de autorización que se solicitarán
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in // Solicita autorización al usuario
            if let error = error { // Comprueba si hay un error
                print("Error: \(error.localizedDescription)") // Imprime el error en la consola
            } else {
                print("Permission granted: \(granted)") // Imprime si el permiso fue concedido
            }
        }
    }
    // Función para programar una notificación local
    func scheduleLocalNotification(movieTitle: String) {
        
        let content = UNMutableNotificationContent() // Crea el contenido de la notificación
        content.title = "Nueva película favorita" // Asigna el título de la notificación
        content.body = "Has añadido a \(movieTitle) a tus películas favoritas" // Asigna el cuerpo de la notificación con el título de la película
        content.sound = UNNotificationSound.default // Asigna el sonido predeterminado a la notificación

        // Configura el disparador para 5 segundos a partir de ahora
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // Crea un disparador de notificación que se activa después de 5 segundos

        // Crea la solicitud de notificación
        let request = UNNotificationRequest(identifier: movieTitle, content: content, trigger: trigger) // Crea la solicitud de notificación con un identificador, contenido y disparador

        // Programa la solicitud con el sistema
        UNUserNotificationCenter.current().add(request) { (error) in // Añade la solicitud al centro de notificaciones
            if let error = error { // Comprueba si hay un error
                print("Error: \(error.localizedDescription)") // Imprime el error en la consola
            }
        }
    }

    // Maneja la notificación cuando la aplicación está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound]) // Muestra una alerta y reproduce un sonido cuando la notificación se presenta en primer plano
    }
}

