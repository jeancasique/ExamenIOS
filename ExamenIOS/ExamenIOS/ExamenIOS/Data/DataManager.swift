import Foundation
import FirebaseFirestore
import FirebaseAuth

class DataManager {
    static let shared = DataManager()
    private let favoritesKey = "favorites"

    // UserDefaults management
    func addFavorite(movieId: String, movieTitle: String) {
        var favorites = fetchFavorites()
        if !favorites.contains(movieId) {
            favorites.append(movieId)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
            print("Favorite movie added to UserDefaults")

            // Add favorite to Firestore
            addFavoriteToFirestore(movieId: movieId, movieTitle: movieTitle)
        }
    }

    func removeFavorite(movieId: String) {
        var favorites = fetchFavorites()
        if let index = favorites.firstIndex(of: movieId) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
            print("Favorite movie removed from UserDefaults")

            // Remove favorite from Firestore
            removeFavoriteFromFirestore(movieId: movieId)
        }
    }

    func isFavorite(movieId: String) -> Bool {
        let favorites = fetchFavorites()
        return favorites.contains(movieId)
    }

    private func fetchFavorites() -> [String] {
        return UserDefaults.standard.array(forKey: favoritesKey) as? [String] ?? []
    }

    private func addFavoriteToFirestore(movieId: String, movieTitle: String) {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let favoriteData: [String: Any] = [
            "movieId": movieId,
            "movieTitle": movieTitle,
            "userId": user.uid,
            "userEmail": user.email ?? "Unknown"
        ]
        db.collection("FavoriteMovie").addDocument(data: favoriteData) { error in
            if let error = error {
                print("Error adding favorite movie to Firestore: \(error)")
            } else {
                print("Favorite movie added to Firestore")
            }
        }
    }

    private func removeFavoriteFromFirestore(movieId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
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
}

