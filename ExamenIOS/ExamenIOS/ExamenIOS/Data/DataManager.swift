import Foundation
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    static let shared = DataManager()
    private let favoritesKey = "favorites"
    private let profileImageURLKey = "profileImageURL"

    // UserDefaults management
    func addFavorite(movieId: String, movieTitle: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica que hay un usuario autenticado
        let db = Firestore.firestore()
        let favoriteData: [String: Any] = [
            "movieId": movieId,
            "movieTitle": movieTitle,
            "userId": userId,
            "userEmail": Auth.auth().currentUser?.email ?? "Unknown"
        ]
        db.collection("FavoriteMovie").addDocument(data: favoriteData) { error in
            if let error = error {
                print("Error adding favorite movie to Firestore: \(error)")
            } else {
                print("Favorite movie added to Firestore")
            }
        }
    }

    func removeFavorite(movieId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica que hay un usuario autenticado
        let db = Firestore.firestore()
        let query = db.collection("FavoriteMovie").whereField("movieId", isEqualTo: movieId).whereField("userId", isEqualTo: userId)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching favorite movie from Firestore: \(error)")
                return
            }
            for document in snapshot!.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error removing favorite movie from Firestore: \(error)")
                    } else {
                        print("Favorite movie removed from Firestore")
                    }
                }
            }
        }
    }

    func isFavorite(movieId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let db = Firestore.firestore()
        let query = db.collection("FavoriteMovie").whereField("movieId", isEqualTo: movieId).whereField("userId", isEqualTo: userId)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching favorite status from Firestore: \(error)")
                completion(false)
                return
            }
            completion(!snapshot!.documents.isEmpty)
        }
    }

    // Cache management for profile image URL
    func cacheProfileImageURL(_ url: String) {
        UserDefaults.standard.set(url, forKey: profileImageURLKey)
    }

    func getCachedProfileImageURL() -> String? {
        return UserDefaults.standard.string(forKey: profileImageURLKey)
    }
}

