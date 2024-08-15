import SwiftUI
import Combine

class PasswordResetViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var emailError: String = ""
    @Published var isEmailSent: Bool = false
    @Published var shouldNavigateToLogin: Bool = false
    
    private var passwordResetModel = PasswordResetModel()
    
    func sendPasswordResetEmail() {
        if !passwordResetModel.isValidEmail(email) {
            self.emailError = "Introduce un correo electrónico válido."
            return
        }
        
        passwordResetModel.checkIfEmailExists(email: email) { result in
            switch result {
            case .failure(let error):
                self.emailError = "Error al verificar el correo: \(error.localizedDescription)"
            case .success(let exists):
                if exists {
                    self.passwordResetModel.resetPassword(email: self.email) { result in
                        switch result {
                        case .failure(let error):
                            self.emailError = "Error al enviar el correo de restablecimiento de contraseña: \(error.localizedDescription)"
                        case .success:
                            self.emailError = ""
                            self.isEmailSent = true
                            self.shouldNavigateToLogin = true
                        }
                    }
                } else {
                    self.emailError = "El correo electrónico no está registrado."
                }
            }
        }
    }
}
