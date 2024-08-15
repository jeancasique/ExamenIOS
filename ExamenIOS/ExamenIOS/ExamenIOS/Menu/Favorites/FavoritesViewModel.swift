import Foundation
import FirebaseAuth
import FirebaseFirestore

class FavoritesViewModel: ObservableObject {
    @Published var favoriteMovies: [Movie] = []
    private let favoritesService = FavoritesService()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadFavoriteMovies() {
        guard let userId = userId else { return }
        favoritesService.fetchFavoriteMovies(for: userId) { [weak self] movies in
            self?.favoriteMovies = movies ?? []
        }
    }

    func filterMovies(searchTerm: String) {
        guard !searchTerm.isEmpty else {
            loadFavoriteMovies()
            return
        }
        favoriteMovies = favoriteMovies.filter { $0.title.lowercased().contains(searchTerm.lowercased()) }
    }

    func loadUserData() {
        guard let userId = userId else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self?.updateUserData(data: data)
                }
            }
        }
    }

    private func updateUserData(data: [String: Any]?) {
        guard let firstName = data?["firstName"] as? String else { return }
        guard let profileImageURL = data?["profileImageURL"] as? String else { return }
        
        // Update session user data
        let session = SessionStore() // Replace with your actual session management logic
        session.userData.firstName = firstName
        
        // Load profile image
        loadProfileImage(from: profileImageURL)
    }

    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let session = SessionStore() // Replace with your actual session management logic
                session.userData.profileImage = UIImage(data: data)
            }
        }.resume()
    }
}
