import SwiftUI
import Combine
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var emailError = ""
    @Published var passwordError = ""
    @Published var isUserLoggedIn = false

     let session: SessionStore
    private var cancellables = Set<AnyCancellable>()
    private let googleSignInManager: GoogleSignInManager
    private let faceIDManager: FaceIDManager
    private let facebookLoginManager: FacebookLoginManager
    private let appleSignInManager: AppleSignInManager

    init(session: SessionStore) {
        self.session = session
        self.googleSignInManager = GoogleSignInManager()
        self.faceIDManager = FaceIDManager()
        self.facebookLoginManager = FacebookLoginManager()
        self.appleSignInManager = AppleSignInManager()
    }
    

    func validateFields() {
        validateEmail(email)
        validatePassword(password)
        
        if emailError.isEmpty && passwordError.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.passwordError = "Error de autenticación: \(error.localizedDescription)"
                } else {
                    self.session.isLoggedIn = true
                    self.isUserLoggedIn = true
                }
            }
        } else {
            self.passwordError = "Por favor corrige los errores antes de continuar."
        }
    }

    func validateEmail(_ email: String) {
        if email.isEmpty {
            emailError = "El correo electrónico es obligatorio."
        } else if !isValidEmail(email) {
            emailError = "Introduce un correo electrónico válido."
        } else {
            emailError = ""
        }
    }

    func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordError = "La contraseña es obligatoria."
        } else if !isValidPassword(password) {
            passwordError = "La contraseña debe tener al menos 5 caracteres, una mayúscula y un número."
        } else {
            passwordError = ""
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        let passwordFormat = "^(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{5,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat)
        return passwordPredicate.evaluate(with: password)
    }

    // Methods for external login
    func authenticateWithFaceID(completion: @escaping (Bool, String?, String?) -> Void) {
        faceIDManager.authenticateWithBiometrics { success, email, password in
            completion(success, email, password)
        }
    }

    func performGoogleSignIn(completion: @escaping (Bool) -> Void) {
        googleSignInManager.performGoogleSignIn { success in
            completion(success)
        }
    }

    func performFacebookSignIn(completion: @escaping (Bool) -> Void) {
        facebookLoginManager.performFacebookLogin { success in
            completion(success)
        }
    }

    func performAppleSignIn(completion: @escaping (String?, String?) -> Void) {
        appleSignInManager.performAppleSignIn { fullName, email in
            completion(fullName, email)
        }
    }

    func saveAppleCredentialsToFirestore(firstName: String, lastName: String, email: String) {
        appleSignInManager.saveCredentialsToFirestore(firstName: firstName, lastName: lastName, email: email)
    }

    func splitFullName(_ fullName: String) -> (String, String) {
        let components = fullName.components(separatedBy: " ")
        let firstName = components.first ?? ""
        let lastName = components.dropFirst().joined(separator: " ")
        return (firstName, lastName)
    }
}

