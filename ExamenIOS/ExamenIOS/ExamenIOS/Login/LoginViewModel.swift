import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import FacebookLogin

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var isUserLoggedIn: Bool = false
    
    private let googleSignInManager = GoogleSignInManager()
    private let appleSignInManager = AppleSignInManager()
    private let faceIDManager = FaceIDManager()
    
    @EnvironmentObject var session: SessionStore

    func validateFields() {
        if emailError.isEmpty && passwordError.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.passwordError = "Error de autenticación: \(error.localizedDescription)"
                } else {
                    self.isUserLoggedIn = true
                }
            }
        } else {
            self.passwordError = "Por favor corrige los errores antes de continuar."
        }
    }
    
    func validateEmail(_ email: String) {
        if email.isEmpty {
            self.emailError = "El correo electrónico es obligatorio."
        } else if !isValidEmail(email) {
            self.emailError = "Introduce un correo electrónico válido."
        } else {
            self.emailError = ""
        }
    }
    
    func validatePassword(_ password: String) {
        if password.isEmpty {
            self.passwordError = "La contraseña es obligatoria."
        } else if !isValidPassword(password) {
            self.passwordError = "La contraseña debe tener al menos 5 caracteres, una mayúscula y un número."
        } else {
            self.passwordError = ""
        }
    }
    
    func signInWithFaceID() {
        faceIDManager.authenticateWithBiometrics { success, email, password in
            if success {
                self.email = email ?? ""
                self.password = password ?? ""
                self.validateFields()
            }
        }
    }
    
    func signInWithGoogle() {
        googleSignInManager.performGoogleSignIn { success in
            if success {
                self.isUserLoggedIn = true
            }
        }
    }
    
    func signInWithApple() {
        appleSignInManager.performAppleSignIn { fullName, email in
            if let fullName = fullName, let email = email {
                let (firstName, lastName) = self.splitFullName(fullName)
                self.appleSignInManager.saveCredentialsToFirestore(firstName: firstName, lastName: lastName, email: email)
                self.isUserLoggedIn = true
            }
        }
    }
    
    private func splitFullName(_ fullName: String) -> (String, String) {
        let components = fullName.components(separatedBy: " ")
        let firstName = components.first ?? ""
        let lastName = components.dropFirst().joined(separator: " ")
        return (firstName, lastName)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordFormat = "^(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{5,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: password)
    }
}

