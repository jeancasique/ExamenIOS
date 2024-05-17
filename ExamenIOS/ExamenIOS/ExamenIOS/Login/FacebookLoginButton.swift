import SwiftUI
import FacebookLogin
import FirebaseAuth
import FacebookCore

struct FacebookLoginButton: UIViewRepresentable {
    @ObservedObject var loginFacebook: LoginFacebook

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
                    self.parent.loginFacebook.isUserLoggedIn = true
                    print("User is signed in with Facebook")
                }
            }
        }

        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            // This won't be called because the original button is hidden
        }

        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            do {
                try Auth.auth().signOut()
                self.parent.loginFacebook.isUserLoggedIn = false
                print("User is signed out")
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError.localizedDescription)")
            }
        }
    }
}

