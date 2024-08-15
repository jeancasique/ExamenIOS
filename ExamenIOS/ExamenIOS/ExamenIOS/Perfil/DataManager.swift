import Foundation
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    
    static let shared = DataManager() // Crea una instancia estática compartida de DataManager
    private let profileImageURLKey = "profileImageURL" // Define una clave para la URL de la imagen de perfil

    // Función para añadir una película a favoritos
    func addFavorite(movieId: String, movieTitle: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica que hay un usuario autenticado
        let db = Firestore.firestore() // Obtiene una referencia a la base de datos de Firestore
        let favoriteData: [String: Any] = [ // Crea un diccionario con los datos de la película favorita
            "movieId": movieId, // ID de la película
            "movieTitle": movieTitle, // Título de la película
            "userId": userId, // ID del usuario
            "userEmail": Auth.auth().currentUser?.email ?? "Unknown" // Email del usuario o "Unknown" si no está disponible
        ]
        db.collection("FavoriteMovie").addDocument(data: favoriteData) { error in // Añade el documento a la colección "FavoriteMovie"
            if let error = error { // Comprueba si hay un error
                print("Error adding favorite movie to Firestore: \(error)") // Imprime el error en la consola
            } else {
                print("Favorite movie added to Firestore") // Imprime un mensaje de éxito
                NotificationManager.shared.scheduleLocalNotification(movieTitle: movieTitle) // Programa una notificación local
            }
        }
    }

    // Función para eliminar una película de favoritos
    func removeFavorite(movieId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica que hay un usuario autenticado
        let db = Firestore.firestore() // Obtiene una referencia a la base de datos de Firestore
        let query = db.collection("FavoriteMovie").whereField("movieId", isEqualTo: movieId).whereField("userId", isEqualTo: userId) // Crea una consulta para encontrar la película favorita del usuario
        query.getDocuments { snapshot, error in // Ejecuta la consulta
            if let error = error { // Comprueba si hay un error
                print("Error fetching favorite movie from Firestore: \(error)") // Imprime el error en la consola
                return
            }
            for document in snapshot!.documents { // Itera sobre los documentos obtenidos
                document.reference.delete { error in // Elimina el documento
                    if let error = error { // Comprueba si hay un error
                        print("Error removing favorite movie from Firestore: \(error)") // Imprime el error en la consola
                    } else {
                        print("Favorite movie removed from Firestore") // Imprime un mensaje de éxito
                    }
                }
            }
        }
    }

    // Función para comprobar si una película es favorita
    func isFavorite(movieId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { // Verifica que hay un usuario autenticado
            completion(false) // Llama al completador con 'false' si no hay usuario
            return
        }
        let db = Firestore.firestore() // Obtiene una referencia a la base de datos de Firestore
        let query = db.collection("FavoriteMovie").whereField("movieId", isEqualTo: movieId).whereField("userId", isEqualTo: userId) // Crea una consulta para encontrar la película favorita del usuario
        query.getDocuments { snapshot, error in // Ejecuta la consulta
            if let error = error { // Comprueba si hay un error
                print("Error fetching favorite status from Firestore: \(error)") // Imprime el error en la consola
                completion(false) // Llama al completador con 'false' si hay un error
                return
            }
            completion(!snapshot!.documents.isEmpty) // Llama al completador con 'true' si la película es favorita, 'false' en caso contrario
        }
    }

    // Función para guardar la URL de la imagen de perfil en la caché
    func cacheProfileImageURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: profileImageURLKey) // Guarda la URL en UserDefaults
    }

    // Función para obtener la URL de la imagen de perfil de la caché
    func getCachedProfileImageURL() -> String? {
        return UserDefaults.standard.string(forKey: profileImageURLKey) // Devuelve la URL guardada en UserDefaults
    }
}

