import FirebaseAuth
import FirebaseFirestore

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userData: UserData? = UserData()

    func listen() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
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

    private func loadUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData?.firstName = data?["firstName"] as? String ?? ""
                    self.userData?.profileImageURL = data?["profileImageURL"] as? String ?? ""
                }
            }
        }
    }
}

