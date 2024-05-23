import SwiftUI
import Firebase
import UIKit

struct PasswordResetView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isEmailValid = true
    @Environment(\.colorScheme) var colorScheme
    @State private var shouldNavigateToLogin = false  // Estado para controlar la navegación

    var body: some View {
        VStack {
            if colorScheme == .dark {
                Image("logoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
            } else {
                Image("lock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
            }

            Text("Se enviará un correo electrónico para restablecer tu contraseña.")
                .font(.caption)
                .padding(.vertical, 8)

            TextField("Correo Electrónico", text: $email)
                .padding()
                .padding(.horizontal, 20) // Asegura espacio para el icono a la izquierda
                .overlay(HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 8) // Añade un poco de espacio desde el borde izquierdo del TextField
                    Spacer() // Empuja el icono hacia la izquierda y el texto del usuario hacia la derecha
                })
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .border(Color(UIColor.separator))
                .padding(.vertical, 20)
                .onChange(of: email, perform: validateEmail)
                .accessibilityLabel("Correo electrónico")
                .accessibilityHint("Introduce tu correo electrónico para restablecer la contraseña")
                .onChange(of: email, perform: { _ in
                    isEmailValid = isValidEmail(email)
                })

            if !isEmailValid {
                Text("Correo electrónico no válido")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Restablecer Contraseña") {
                if email.isEmpty {
                    alertMessage = "Por favor, introduce un correo electrónico."
                    showAlert = true
                    shouldNavigateToLogin = false // No navegar a LoginView si el correo está vacío
                } else {
                    checkIfEmailExistsAndResetPassword()
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(isEmailValid ? Color.blue : Color.gray)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white) // Ajusta el color de fondo del VStack según el modo de interfaz
        .navigationTitle("Restablecer Contraseña")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Recuperar Contraseña"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"), action: {
                    if shouldNavigateToLogin {
                        // Activar la navegación solo si debería navegar a LoginView
                        shouldNavigateToLogin = true
                    }
                })
            )
        }
        .background(
            NavigationLink("", destination: LoginView(), isActive: $shouldNavigateToLogin) // NavigationLink oculto
        )
    }

    private func checkIfEmailExistsAndResetPassword() {
        if isEmailValid {
            let lowercasedEmail = email.lowercased() // Convertir el correo electrónico a minúsculas
            print("Lowercased email: \(lowercasedEmail)") // Depuración
            let db = Firestore.firestore()
            db.collection("users").whereField("email", isEqualTo: lowercasedEmail).getDocuments { (snapshot, error) in
                if let error = error {
                    alertMessage = "Error al verificar el correo: \(error.localizedDescription)"
                    showAlert = true
                    shouldNavigateToLogin = false
                } else if snapshot?.documents.isEmpty == true {
                    alertMessage = "El correo electrónico no está registrado."
                    showAlert = true
                    shouldNavigateToLogin = false
                } else {
                    // El correo electrónico está registrado, proceder con el restablecimiento de la contraseña
                    resetPassword(lowercasedEmail)
                }
            }
        } else {
            alertMessage = "Por favor, introduce un correo electrónico válido."
            showAlert = true
            shouldNavigateToLogin = false // No navegar a LoginView si el correo no es válido
        }
    }


    private func resetPassword(_ email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = "Error al enviar el correo electrónico de restablecimiento de contraseña: \(error.localizedDescription)"
                showAlert = true
                shouldNavigateToLogin = false // No navegar a LoginView en caso de error
            } else {
                alertMessage = "Se ha enviado un correo electrónico de restablecimiento de contraseña a \(email). Por favor, verifica tu bandeja de entrada."
                self.email = ""
                showAlert = true
                shouldNavigateToLogin = true // Navegar a LoginView en caso de éxito
            }
        }
    }

    private func validateEmail(_ email: String) {
        isEmailValid = isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PasswordResetView()
                .preferredColorScheme(.dark)
            
            PasswordResetView()
                .preferredColorScheme(.light)
        }
    }
}

