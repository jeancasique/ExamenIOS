import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                print("Permission granted: \(granted)")
            }
        }
    }

    func scheduleLocalNotification(movieTitle: String) {
        let content = UNMutableNotificationContent()
        content.title = "Nueva película favorita"
        content.body = "Has añadido a \(movieTitle) a tus películas favoritas"
        content.sound = UNNotificationSound.default

        // Configure the trigger for 5 seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // Create the request
        let request = UNNotificationRequest(identifier: movieTitle, content: content, trigger: trigger)

        // Schedule the request with the system
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    // Handle notification when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

