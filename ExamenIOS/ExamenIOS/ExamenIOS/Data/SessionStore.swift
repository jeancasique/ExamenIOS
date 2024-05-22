import FirebaseAuth
import FirebaseFirestore
import FacebookLogin
import SwiftUI

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userData: UserData = UserData()

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
            let loginManager = LoginManager()
            loginManager.logOut()
            self.isLoggedIn = false
            self.userData = UserData()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func loadUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData.email = data?["email"] as? String ?? ""
                    self.userData.firstName = data?["firstName"] as? String ?? ""
                    self.userData.lastName = data?["lastName"] as? String ?? ""
                    self.userData.profileImageURL = data?["profileImageURL"] as? String ?? ""
                    self.loadProfileImage(from: self.userData.profileImageURL ?? "")
                }
            }
        }
    }

    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.userData.profileImage = UIImage(data: data)
            }
        }.resume()
    }

    func updateUserDataFromFacebook(firstName: String, lastName: String, profileImageURL: String) {
        DispatchQueue.main.async {
            self.userData.firstName = firstName
            self.userData.lastName = lastName
            self.userData.profileImageURL = profileImageURL
            self.loadProfileImage(from: profileImageURL)
        }
    }
}

