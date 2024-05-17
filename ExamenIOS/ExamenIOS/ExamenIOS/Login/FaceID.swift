import SwiftUI
import LocalAuthentication

class FaceIDManager: NSObject {
    
    func authenticateWithBiometrics(completion: @escaping (Bool, String?, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autenticarse con Face ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        let email = KeychainService.loadEmail()
                        let password = KeychainService.loadPassword()
                        completion(true, email, password)
                    } else {
                        print("La autenticación con Face ID falló o fue cancelada.")
                        completion(false, nil, nil)
                    }
                }
            }
        } else {
            let alertController = UIAlertController(title: "No compatible", message: "Tu dispositivo no es compatible con Face ID", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            if let viewController = UIApplication.shared.windows.first?.rootViewController {
                viewController.present(alertController, animated: true, completion: nil)
            }
            completion(false, nil, nil)
        }
    }
}
