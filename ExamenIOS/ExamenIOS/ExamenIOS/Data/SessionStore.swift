import FirebaseAuth
import FirebaseFirestore

// Define la clase SessionStore que implementa ObservableObject para que pueda ser observada por las vistas
class SessionStore: ObservableObject {
    
    @Published var isLoggedIn: Bool = false // Publica la variable isLoggedIn para notificar los cambios a las vistas
    @Published var userData: UserData? = UserData() // Publica la variable userData para notificar los cambios a las vistas

    
    // Función para escuchar los cambios en el estado de autenticación
    func listen() {
        
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in // Añade un listener para cambios en el estado de autenticación
            if let user = user { // Si hay un usuario autenticado
                self?.isLoggedIn = true // Establece isLoggedIn a true
                self?.loadUserData(userId: user.uid) // Carga los datos del usuario
            } else { // Si no hay un usuario autenticado
                self?.isLoggedIn = false // Establece isLoggedIn a false
                self?.userData = UserData() // Establece userData a una nueva instancia vacía de UserData
            }
        }
    }
    
    // Función para cerrar sesión
    func signOut() {
        do {
            try Auth.auth().signOut() // Intenta cerrar sesión
            self.isLoggedIn = false // Establece isLoggedIn a false
            self.userData = UserData() // Establece userData a una nueva instancia vacía de UserData
        } catch {
            print("Error signing out: \(error.localizedDescription)") // Imprime un mensaje de error si ocurre un problema al cerrar sesión
        }
    }
    
    // Función privada para cargar los datos del usuario desde Firestore
    private func loadUserData(userId: String) {
        
        let db = Firestore.firestore() // Obtiene una referencia a la base de datos de Firestore
        db.collection("users").document(userId).getDocument { (document, error) in // Obtiene el documento del usuario desde la colección "users"
            if let document = document, document.exists { // Si el documento existe
                let data = document.data() // Obtiene los datos del documento
                DispatchQueue.main.async { // Actualiza la interfaz de usuario en el hilo principal
                    self.userData?.firstName = data?["firstName"] as? String ?? "" // Asigna el primer nombre del usuario
                    self.userData?.profileImageURL = data?["profileImageURL"] as? String ?? "" // Asigna la URL de la imagen de perfil del usuario
                }
            }
        }
    }
}

