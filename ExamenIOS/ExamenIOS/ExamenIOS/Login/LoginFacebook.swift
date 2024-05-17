import FacebookLogin
import FirebaseAuth
import SwiftUI
import FacebookCore
import FirebaseFirestore

class LoginFacebook: ObservableObject {
    @Published var isUserLoggedIn: Bool = false

    init() {
        checkExistingToken()
    }

    func checkExistingToken() {
        if let token = AccessToken.current, !token.isExpired {
            self.isUserLoggedIn = true
            print("User is already logged in with Facebook")
            fetchFacebookUserData()
        } else {
            self.isUserLoggedIn = false
        }
    }

    func login(completion: @escaping (Bool) -> Void) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                completion(false)
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Facebook authentication failed: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                self.isUserLoggedIn = true
                self.fetchFacebookUserData()
                completion(true)
                print("User is signed in with Facebook")
            }
        }
    }

    func fetchFacebookUserData() {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me", parameters: ["fields": "id, email, name, picture.type(large)"])) { httpResponse, result, error in
            if let error = error {
                print("Failed to get user data: \(error.localizedDescription)")
                return
            }

            guard let result = result as? [String: Any] else { return }
            let email = result["email"] as? String ?? ""
            let name = result["name"] as? String ?? ""
            let picture = (result["picture"] as? [String: Any])?["data"] as? [String: Any]
            let profileImageURL = picture?["url"] as? String ?? ""

            self.saveUserDataToFirestore(email: email, name: name, profileImageURL: profileImageURL)
        }
        connection.start()
    }

    func saveUserDataToFirestore(email: String, name: String, profileImageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": email,
            "name": name,
            "profileImageURL": profileImageURL
        ]
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error saving user data: \(error.localizedDescription)")
            } else {
                print("User data saved successfully")
            }
        }
    }

    func logout() {
        let loginManager = LoginManager()
        loginManager.logOut()
        do {
            try Auth.auth().signOut()
            self.isUserLoggedIn = false
            print("User is signed out")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}

