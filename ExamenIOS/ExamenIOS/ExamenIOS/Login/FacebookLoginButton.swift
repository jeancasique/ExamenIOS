import SwiftUI
import FacebookLogin
import FirebaseAuth
import FacebookCore
import FirebaseFirestore

struct FacebookLoginButton: UIViewRepresentable {
    @EnvironmentObject var session: SessionStore

    func makeUIView(context: Context) -> UIView {
        let container = UIView()

        // Create custom button view with logo
        let customButton = UIButton(type: .custom)
        customButton.setImage(UIImage(named: "logoFacebook"), for: .normal)
        customButton.tintColor = .blue
        customButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        customButton.addTarget(context.coordinator, action: #selector(Coordinator.didTapCustomButton), for: .touchUpInside)

        container.addSubview(customButton)
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No se necesita implementar esta función para nuestro propósito actual
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, LoginButtonDelegate {
        var parent: FacebookLoginButton

        init(_ parent: FacebookLoginButton) {
            self.parent = parent
            super.init()
            checkExistingToken()
        }

        @objc func didTapCustomButton() {
            let loginManager = LoginManager()
            loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
                if let error = error {
                    print("Error logging in with Facebook: \(error.localizedDescription)")
                    return
                }

                guard let accessToken = AccessToken.current else {
                    print("Failed to get access token")
                    return
                }

                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        print("Facebook authentication failed: \(error.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.fetchFacebookUserData()
                    }
                }
            }
        }

        func checkExistingToken() {
            if let token = AccessToken.current, !token.isExpired {
                DispatchQueue.main.async {
                    self.parent.session.isLoggedIn = true
                }
                print("User is already logged in with Facebook")
                fetchFacebookUserData()
            } else {
                DispatchQueue.main.async {
                    self.parent.session.isLoggedIn = false
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
                let fullName = result["name"] as? String ?? ""
                let picture = (result["picture"] as? [String: Any])?["data"] as? [String: Any]
                let profileImageURL = picture?["url"] as? String ?? ""

                // Separar el nombre completo en firstName y lastName
                let nameComponents = fullName.split(separator: " ")
                let firstName = nameComponents.first.map(String.init) ?? ""
                let lastName = nameComponents.dropFirst().joined(separator: " ")

                DispatchQueue.main.async {
                    self.saveUserDataToFirestore(email: email, firstName: firstName, lastName: lastName, profileImageURL: profileImageURL)
                }
            }
            connection.start()
        }

        func saveUserDataToFirestore(email: String, firstName: String, lastName: String, profileImageURL: String) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let userData: [String: Any] = [
                "email": email,
                "firstName": firstName, // Guardar el primer nombre
                "lastName": lastName, // Guardar el apellido
                "profileImageURL": profileImageURL
            ]
            db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    print("Error saving user data: \(error.localizedDescription)")
                } else {
                    print("User data saved successfully")
                    DispatchQueue.main.async {
                        self.updateSessionStore(firstName: firstName, lastName: lastName, profileImageURL: profileImageURL)
                    }
                }
            }
        }

        func updateSessionStore(firstName: String, lastName: String, profileImageURL: String) {
            DispatchQueue.main.async {
                self.parent.session.updateUserDataFromFacebook(firstName: firstName, lastName: lastName, profileImageURL: profileImageURL)
                self.parent.session.isLoggedIn = true
            }
        }

        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            // This won't be called because the original button is hidden
        }

        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            do {
                try Auth.auth().signOut()
                DispatchQueue.main.async {
                    self.parent.session.isLoggedIn = false
                }
                print("User is signed out")
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
    }
}

