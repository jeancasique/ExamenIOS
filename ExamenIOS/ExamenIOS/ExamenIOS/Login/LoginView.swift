import SwiftUI
import FirebaseAuth

// Define la estructura LoginView que conforma el protocolo View
struct LoginView: View {
    
    @EnvironmentObject var session: SessionStore // Obtiene la sesión del usuario desde el entorno
    @State private var email = "" // Declara una variable de estado para almacenar el correo electrónico
    @State private var password = "" // Declara una variable de estado para almacenar la contraseña
    @State private var emailError = "" // Declara una variable de estado para almacenar el mensaje de error del correo electrónico
    @State private var passwordError = "" // Declara una variable de estado para almacenar el mensaje de error de la contraseña
    @State private var isUserLoggedIn = false // Declara una variable de estado para controlar si el usuario está logueado
    @Environment(\.colorScheme) var colorScheme // Obtiene el esquema de color actual (modo oscuro o claro)
    @StateObject var userData = UserData() // Declara un objeto de estado para almacenar los datos del usuario
    
    // Managers para diferentes métodos de autenticación
    private let googleSignInManager = GoogleSignInManager() // Instancia el administrador de inicio de sesión de Google
    private let appleSignInManager = AppleSignInManager() // Instancia el administrador de inicio de sesión de Apple
    private let faceIDManager = FaceIDManager() // Instancia el administrador de Face ID
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    emailField // Muestra el campo de correo electrónico
                    passwordField // Muestra el campo de contraseña
                    actionButtons // Muestra los botones de acción
                    Spacer() // Añade un espaciador para empujar todo hacia arriba
                }
                .foregroundColor(.primary) // Establece el color del contenido
                .padding() // Añade relleno alrededor del VStack
                .navigationTitle("Iniciar Sesión") // Establece el título de la barra de navegación
                .navigationBarTitleDisplayMode(.inline) // Establece el modo de visualización del título
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EmptyView() // Añade una vista vacía para ocultar el botón de retroceso en MoviesView
                    }
                }
                .navigationDestination(isPresented: $isUserLoggedIn) { // Navega a MoviesView si el usuario está logueado
                    MoviesView().environmentObject(userData) // Pasa los datos del usuario al entorno de MoviesView
                        .navigationBarBackButtonHidden(true) // Oculta el botón de retroceso
                }
            }
        }
    }
    // Define la vista para el campo de correo electrónico
    private var emailField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "envelope.fill") // Muestra un icono de sobre
                    .foregroundColor(.gray) // Establece el color del icono a gris
                    .padding(.leading, 8) // Añade relleno a la izquierda del icono
                TextField("Correo Electrónico", text: $email) // Muestra un campo de texto para el correo electrónico
                    .padding(.vertical, 20) // Añade relleno vertical al campo de texto
                    .autocapitalization(.none) // Desactiva la capitalización automática
                    .keyboardType(.emailAddress) // Establece el tipo de teclado a dirección de correo electrónico
                    .disableAutocorrection(true) // Desactiva la corrección automática
            }
            .border(Color(UIColor.separator)) // Añade un borde al HStack
            .padding(.horizontal, 8) // Añade relleno horizontal al HStack
            .padding(.vertical, 20) // Añade relleno vertical al HStack
            .onChange(of: email, perform: validateEmail) // Valida el correo electrónico cuando cambia
            .submitLabel(.next) // Establece la etiqueta del botón de envío a "next"
            
            if !emailError.isEmpty { // Si hay un error en el correo electrónico
                Text(emailError) // Muestra el mensaje de error
                    .foregroundColor(.red) // Establece el color del texto a rojo
                    .font(.caption) // Establece la fuente a caption
                    .padding([.horizontal, .top], 4) // Añade relleno horizontal y superior
            }
        }
    }
    // Define la vista para el campo de contraseña
    private var passwordField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "key.fill") // Muestra un icono de llave
                    .foregroundColor(.gray) // Establece el color del icono a gris
                    .padding(.leading, 8) // Añade relleno a la izquierda del icono
                SecureField("Contraseña", text: $password) // Muestra un campo de texto seguro para la contraseña
                    .padding(.vertical, 20) // Añade relleno vertical al campo de texto
            }
            .border(Color(UIColor.separator)) // Añade un borde al HStack
            .padding(.horizontal, 8) // Añade relleno horizontal al HStack
            .padding(.vertical, 20) // Añade relleno vertical al HStack
            .onChange(of: password, perform: validatePassword) // Valida la contraseña cuando cambia
            .submitLabel(.done) // Establece la etiqueta del botón de envío a "done"
            
            if !passwordError.isEmpty { // Si hay un error en la contraseña
                Text(passwordError) // Muestra el mensaje de error
                    .foregroundColor(.red) // Establece el color del texto a rojo
                    .font(.caption) // Establece la fuente a caption
                    .padding([.horizontal, .top], 4) // Añade relleno horizontal y superior
            }
        }
    }
    // Define la vista para los botones de acción
    private var actionButtons: some View {
        VStack {
            HStack(spacing: 60) {
                Button("Iniciar Sesión") {
                    validateFields() // Llama a la función para validar los campos
                }
                .padding() // Añade relleno alrededor del botón
                .foregroundColor(.white) // Establece el color del texto a blanco
                .background(Color.blue) // Establece el color de fondo a azul
                .cornerRadius(8) // Añade esquinas redondeadas al botón
                
                NavigationLink("Registro", destination: RegistrationView()) // Enlace de navegación a la vista de registro
                    .padding() // Añade relleno alrededor del enlace
                    .foregroundColor(.white) // Establece el color del texto a blanco
                    .background(Color.green) // Establece el color de fondo a verde
                    .cornerRadius(8) // Añade esquinas redondeadas al enlace
            }
            .padding() // Añade relleno alrededor del HStack
            
            NavigationLink(destination: PasswordResetView()) { // Enlace de navegación a la vista de restablecimiento de contraseña
                Text("¿Olvidaste tu contraseña?") // Texto del enlace
                    .foregroundColor(.blue) // Establece el color del texto a azul
            }
            
            Button(action: { // Botón para iniciar sesión con Face ID
                faceIDManager.authenticateWithBiometrics { success, email, password in // Llama a la función de autenticación con Face ID
                    if success { // Si la autenticación es exitosa
                        self.email = email ?? "" // Asigna el correo electrónico
                        self.password = password ?? "" // Asigna la contraseña
                        self.validateFields() // Llama a la función para validar los campos
                    }
                }
            }) {
                HStack {
                    Image(systemName: "faceid") // Muestra un icono de Face ID
                    Text("Inicia Sesión con Face ID") // Texto del botón
                }
                .padding(8) // Añade relleno alrededor del HStack
            }
            
            HStack(spacing: 20) {
                
                // Botón para iniciar sesión con Google
                Button(action: {
                    googleSignInManager.performGoogleSignIn { success in // Llama a la función de inicio de sesión con Google
                        if success { // Si el inicio de sesión es exitoso
                            self.isUserLoggedIn = true // Establece isUserLoggedIn a true
                        }
                    }
                }) {
                    Image("googleLogo") // Muestra el logo de Google
                        .resizable() // Permite redimensionar el logo
                        .aspectRatio(contentMode: .fit) // Mantiene la proporción del contenido
                        .frame(width: 40, height: 40) // Establece el tamaño del logo
                        .foregroundColor(.red) // Establece el color del logo a rojo
                        .padding(8) // Añade relleno alrededor del logo
                        .background(colorScheme == .dark ? Color.clear : Color.white) // Establece el color de fondo según el esquema de color
                        .cornerRadius(8) // Añade esquinas redondeadas al logo
                }
                // Botón para iniciar sesión con Apple
                Button(action: {
                    appleSignInManager.performAppleSignIn { fullName, email in // Llama a la función de inicio de sesión con Apple
                        if let fullName = fullName, let email = email { // Si se obtiene el nombre completo y el correo electrónico
                            let (firstName, lastName) = splitFullName(fullName) // Divide el nombre completo en nombre y apellidos
                            appleSignInManager.saveCredentialsToFirestore(firstName: firstName, lastName: lastName, email: email) // Guarda las credenciales en Firestore
                            self.isUserLoggedIn = true // Establece isUserLoggedIn a true
                        }
                    }
                }) {
                    Image(systemName: "applelogo") // Muestra el logo de Apple
                        .resizable() // Permite redimensionar el logo
                        .aspectRatio(contentMode: .fit) // Mantiene la proporción del contenido
                        .frame(width: 40, height: 40) // Establece el tamaño del logo
                        .padding(8) // Añade relleno alrededor del logo
                        .background(colorScheme == .dark ? Color.black : Color.white) // Establece el color de fondo según el esquema de color
                        .cornerRadius(8) // Añade esquinas redondeadas al logo
                }
            }
            .padding(2) // Añade relleno alrededor del HStack
        }
    }
    // Función para validar los campos de correo electrónico y contraseña
    private func validateFields() {
        
        if emailError.isEmpty && passwordError.isEmpty { // Si no hay errores en el correo electrónico y la contraseña
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in // Intenta iniciar sesión con FirebaseAuth
                if let error = error { // Si ocurre un error
                    self.passwordError = "Error de autenticación: \(error.localizedDescription)" // Muestra el mensaje de error
                } else {
                    self.isUserLoggedIn = true // Establece isUserLoggedIn a true
                }
            }
        } else {
            self.passwordError = "Por favor corrige los errores antes de continuar." // Muestra un mensaje indicando que hay errores por corregir
        }
    }
    // Función para validar el correo electrónico
    private func validateEmail(_ email: String) {
        
        if email.isEmpty { // Si el correo electrónico está vacío
            self.emailError = "El correo electrónico es obligatorio." // Muestra un mensaje indicando que el correo electrónico es obligatorio
        } else if !isValidEmail(email) { // Si el correo electrónico no es válido
            self.emailError = "Introduce un correo electrónico válido." // Muestra un mensaje indicando que el correo electrónico no es válido
        } else {
            self.emailError = "" // No hay errores en el correo electrónico
        }
    }
    // Función para validar la contraseña
    private func validatePassword(_ password: String) {
        
        if password.isEmpty { // Si la contraseña está vacía
            self.passwordError = "La contraseña es obligatoria." // Muestra un mensaje indicando que la contraseña es obligatoria
        } else if !isValidPassword(password) { // Si la contraseña no es válida
            self.passwordError = "La contraseña debe tener al menos 5 caracteres, una mayúscula y un número." // Muestra un mensaje indicando que la contraseña no cumple con los requisitos
        } else {
            self.passwordError = "" // No hay errores en la contraseña
        }
    }
    // Función para verificar si el correo electrónico es válido
    func isValidEmail(_ email: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}" // Expresión regular para el formato de correo electrónico
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat) // Predicado para evaluar el correo electrónico
        return emailPredicate.evaluate(with: email) // Retorna true si el correo electrónico es válido
    }
    // Función para verificar si la contraseña es válida
    func isValidPassword(_ password: String) -> Bool {
        
        let passwordFormat = "^(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d]{5,}$" // Expresión regular para el formato de contraseña
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordFormat) // Predicado para evaluar la contraseña
        return passwordPredicate.evaluate(with: password) // Retorna true si la contraseña es válida
    }
    // Función para dividir el nombre completo en nombre y apellidos
    private func splitFullName(_ fullName: String) -> (String, String) {
        
        let components = fullName.components(separatedBy: " ") // Divide el nombre completo por espacios
        let firstName = components.first ?? "" // Obtiene el primer nombre
        let lastName = components.dropFirst().joined(separator: " ") // Une el resto como apellidos
        return (firstName, lastName) // Retorna el nombre y los apellidos
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

