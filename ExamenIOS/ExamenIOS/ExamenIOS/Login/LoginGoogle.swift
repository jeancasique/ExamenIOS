import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class GoogleSignInManager: NSObject {
    
    func performGoogleSignIn(completion: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Fallo al iniciar sesión con Google")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let viewController: UIViewController = (UIApplication.shared.windows.first?.rootViewController!)!
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signResult, error in
            if let error = error {
                print(error)
                completion(false)
                return
            }
            
            guard let googleUser = signResult?.user,
                  let idToken = googleUser.idToken else {
                completion(false)
                return
            }
            
            let accessToken = googleUser.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error durante el inicio de sesión con Google: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let user = Auth.auth().currentUser else {
                    print("Error: No se pudo obtener el usuario actual.")
                    completion(false)
                    return
                }
                
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(user.uid)
                Task {
                    do {
                        let document = try await docRef.getDocument()
                        if !document.exists {
                            let firstName = googleUser.profile?.givenName ?? ""
                            let lastName = googleUser.profile?.familyName ?? ""
                            let profileImageURL = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
                            
                            let userData: [String: Any] = [
                                "email": user.email ?? "",
                                "firstName": firstName,
                                "lastName": lastName,
                                "profileImageURL": profileImageURL
                            ]
                            
                            db.collection("users").document(user.uid).setData(userData) { error in
                                if let error = error {
                                    print("Error al guardar los datos del usuario: \(error.localizedDescription)")
                                } else {
                                    print("Datos del usuario guardados correctamente.")
                                    DispatchQueue.main.async {
                                        completion(true)
                                    }
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true)
                            }
                        }
                    } catch {
                        print(error)
                        completion(false)
                    }
                }
            }
        }
    }
}

