import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class RegistrationViewModel: ObservableObject {
    @Published var registrationData = RegistrationModel()
    @Published var formErrors = [String: String]()
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var shouldNavigateToLogin = false
    @Published var showTermsSheet = false
    @Published var emailAlreadyRegistered = false
    @Published var showPassword = false
    @Published var showConfirmPassword = false

    private var db = Firestore.firestore()
    
    var allFieldsFilled: Bool {
        !registrationData.name.isEmpty &&
        !registrationData.lastName.isEmpty &&
        !registrationData.email.isEmpty &&
        !registrationData.password.isEmpty &&
        registrationData.password == registrationData.confirmPassword &&
        !registrationData.gender.isEmpty &&
        registrationData.birthDate != nil
    }

    func validateAndCreateUser() {
        formErrors.removeAll()

        validateField("name", value: registrationData.name, errorMessage: "El nombre es obligatorio.")
        validateField("lastName", value: registrationData.lastName, errorMessage: "Los apellidos son obligatorios.")
        validateField("gender", value: registrationData.gender, errorMessage: "El sexo es obligatorio.")
        validateField("email", value: registrationData.email, errorMessage: "El correo electrónico es obligatorio.", validation: isValidEmail)
        validateField("password", value: registrationData.password, errorMessage: "La contraseña es obligatoria.", validation: isValidPassword)
        if registrationData.password != registrationData.confirmPassword {
            formErrors["confirmPassword"] = "Las contraseñas no coinciden."
        }

        if let date = registrationData.birthDate {
            checkAge(date: date)
        } else {
            formErrors["birthDate"] = "La fecha de nacimiento es obligatoria."
        }

        if formErrors.isEmpty && allFieldsFilled && !emailAlreadyRegistered {
            Auth.auth().createUser(withEmail: registrationData.email.lowercased(), password: registrationData.password) { authResult, error in
                if let user = authResult?.user, error == nil {
                    self.saveUserData(user)
                } else {
                    self.alertMessage = "Error al crear el usuario: \(error?.localizedDescription ?? "")"
                    self.showAlert = true
                }
            }
        } else {
            self.alertMessage = "Por favor, corrige los errores para continuar."
            self.showAlert = true
        }
    }

    private func validateField(_ field: String, value: String, errorMessage: String, validation: ((String) -> Bool)? = nil) {
        if value.isEmpty {
            formErrors[field] = errorMessage
        } else {
            if let validation = validation, !validation(value) {
                if field == "password" && !isValidPassword(value) {
                    formErrors[field] = "La contraseña debe tener mínimo 5 caracteres, una mayúscula y un número."
                } else {
                    formErrors[field] = errorMessage
                }
            } else {
                formErrors[field] = nil
            }
        }
    }

    private func saveUserData(_ user: User) {
        let userData = [
            "email": registrationData.email.lowercased(),
            "firstName": registrationData.name,
            "lastName": registrationData.lastName,
            "birthDate": "\(registrationData.birthDate!)",
            "gender": registrationData.gender
        ]
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                self.alertMessage = "Error al guardar datos del usuario: \(error.localizedDescription)"
                self.showAlert = true
            } else {
                self.alertMessage = "Registro exitoso. Por favor inicia sesión con tus nuevas credenciales."
                self.showAlert = true
                self.shouldNavigateToLogin = true
            }
        }
    }

     func checkAge(date: Date) {
        let ageComponents = Calendar.current.dateComponents([.year], from: date, to: Date())
        if let age = ageComponents.year, age < 18 {
            formErrors["birthDate"] = "No puedes registrarte siendo menor de edad."
        } else {
            formErrors["birthDate"] = nil
        }
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

    func checkIfEmailExists(email: String) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error al verificar el correo: \(error.localizedDescription)")
            } else if snapshot?.documents.isEmpty == false {
                self.emailAlreadyRegistered = true
            } else {
                self.emailAlreadyRegistered = false
            }
        }
    }
}

