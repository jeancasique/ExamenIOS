import SwiftUI
import FirebaseAuth
import FacebookCore
import FacebookLogin

struct LoginView: View {
    
    @EnvironmentObject var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var isUserLoggedIn = false
    @Environment(\.colorScheme) var colorScheme
    @StateObject var userData = UserData()
    
    private let googleSignInManager = GoogleSignInManager()
    private let appleSignInManager = AppleSignInManager()
    private let faceIDManager = FaceIDManager()
    @StateObject private var facebookLoginManager = LoginFacebook()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    emailField
                    passwordField
                    actionButtons
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding()
                .navigationTitle("Iniciar Sesión")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EmptyView()
                    }
                }
                .onAppear {
                    facebookLoginManager.checkExistingToken()
                    if facebookLoginManager.isUserLoggedIn {
                        session.isLoggedIn = true
                    }
                }
                .navigationDestination(isPresented: $session.isLoggedIn) {
                    MoviesView().environmentObject(userData)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                TextField("Correo Electrónico", text: $email)
                    .padding(.vertical, 20)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
            }
            .border(Color(UIColor.separator))
            .padding(.horizontal, 8)
            .padding(.vertical, 20)
            .onChange(of: email, perform: validateEmail)
            .submitLabel(.next)
            
            if !emailError.isEmpty {
                Text(emailError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding([.horizontal, .top], 4)
            }
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                SecureField("Contraseña", text: $password)
                    .padding(.vertical, 20)
            }
            .border(Color(UIColor.separator))
            .padding(.horizontal, 8)
            .padding(.vertical, 20)
            .onChange(of: password, perform: validatePassword)
            .submitLabel(.done)
            
            if !passwordError.isEmpty {
                Text(passwordError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding([.horizontal, .top], 4)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack {
            HStack(spacing: 60) {
                Button("Iniciar Sesión") {
                    validateFields()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                
                NavigationLink("Registro", destination: RegistrationView())
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding()
            
            NavigationLink(destination: PasswordResetView()) {
                Text("¿Olvidaste tu contraseña?")
                    .foregroundColor(.blue)
            }
            
            Button(action: {
                faceIDManager.authenticateWithBiometrics { success, email, password in
                    if success {
                        self.email = email ?? ""
                        self.password = password ?? ""
                        self.validateFields()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Inicia Sesión con Face ID")
                }
                .padding(8)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    googleSignInManager.performGoogleSignIn { success in
                        if success {
                            session.isLoggedIn = true
                        }
                    }
                }) {
                    Image("googleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.clear : Color.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    appleSignInManager.performAppleSignIn { fullName, email in
                        if let fullName = fullName, let email = email {
                            let (firstName, lastName) = splitFullName(fullName)
                            appleSignInManager.saveCredentialsToFirestore(firstName: firstName, lastName: lastName, email: email)
                            session.isLoggedIn = true
                        }
                    }
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .cornerRadius(8)
                }
                
                FacebookLoginButton(loginFacebook: facebookLoginManager)
                    .frame(width: 60, height: 60)
                    .padding(8)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
            }
            .padding(2)
        }
    }
    
    private func validateFields() {
        if emailError.isEmpty && passwordError.isEmpty {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    self.passwordError = "Error de autenticación: \(error.localizedDescription)"
                } else {
                    session.isLoggedIn = true
                }
            }
        } else {
            self.passwordError = "Por favor corrige los errores antes de continuar."
        }
    }
    
    private func validateEmail(_ email: String) {
        if email.isEmpty {
            self.emailError = "El correo electrónico es obligatorio."
        } else if !isValidEmail(email) {
            self.emailError = "Introduce un correo electrónico válido."
        } else {
            self.emailError = ""
        }
    }
    
    private func validatePassword(_ password: String) {
        if password.isEmpty {
            self.passwordError = "La contraseña es obligatoria."
        } else if !isValidPassword(password) {
            self.passwordError = "La contraseña debe tener al menos 5 caracteres, una mayúscula y un número."
        } else {
            self.passwordError = ""
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
    
    private func splitFullName(_ fullName: String) -> (String, String) {
        let components = fullName.components(separatedBy: " ")
        let firstName = components.first ?? ""
        let lastName = components.dropFirst().joined(separator: " ")
        return (firstName, lastName)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.dark)
            
            LoginView()
                .preferredColorScheme(.light)
        }
    }
}

