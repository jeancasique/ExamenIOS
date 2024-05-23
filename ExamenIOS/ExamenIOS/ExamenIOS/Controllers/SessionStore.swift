import Firebase
import FirebaseAuth
import FirebaseFirestore

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userData: UserData = UserData()
    @Published var currentView: CurrentView = .home

    func listen() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.isLoggedIn = true
                self?.loadUserData(userId: user.uid)
            } else {
                self?.isLoggedIn = false
                self?.userData = UserData()
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.userData = UserData()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func loadUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self?.userData.email = data?["email"] as? String ?? ""
                    self?.userData.firstName = data?["firstName"] as? String ?? ""
                    self?.userData.lastName = data?["lastName"] as? String ?? ""
                    self?.userData.gender = data?["gender"] as? String ?? ""
                    if let birthDate = data?["birthDate"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        if let date = dateFormatter.date(from: birthDate) {
                            self?.userData.birthDate = date
                        }
                    }
                    if let profileImageURL = data?["profileImageURL"] as? String {
                        self?.userData.profileImageURL = profileImageURL
                        self?.loadProfileImage(from: profileImageURL)
                    }
                }
            }
        }
    }

    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.userData.profileImage = UIImage(data: data)
            }
        }.resume()
    }
    enum CurrentView {
        case home
        case profile
        case favorites
        case settings
    }
    // Método para actualizar los datos del usuario desde Facebook
       func updateUserDataFromFacebook(firstName: String, lastName: String, profileImageURL: String) {
           self.userData.firstName = firstName
           self.userData.lastName = lastName
           self.userData.profileImageURL = profileImageURL
       }
}

