import SwiftUI
import FirebaseAuth
import AuthenticationServices
import FirebaseFirestore

class AppleSignInManager: NSObject {
    
    func performAppleSignIn(completion: @escaping (String?, String?) -> Void) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = ASAuthorizationControllerDelegateImpl(completion: completion)
        controller.presentationContextProvider = controller.delegate as? ASAuthorizationControllerPresentationContextProviding
        controller.performRequests()
    }

    func saveCredentialsToFirestore(firstName: String, lastName: String, email: String) { // Cambiado a público
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        
        db.collection("users").document(email).setData(userData) { error in
            if let error = error {
                print("Error al guardar los datos del usuario en Firestore: \(error.localizedDescription)")
            } else {
                print("Datos del usuario guardados correctamente en Firestore.")
            }
        }
    }
}

class ASAuthorizationControllerDelegateImpl: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    var completion: ((String?, String?) -> Void)?
    
    init(completion: @escaping (String?, String?) -> Void) {
        self.completion = completion
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let fullName = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
            let email = appleIDCredential.email ?? ""
            completion?(fullName, email)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error de autenticación con Apple: \(error.localizedDescription)")
    }
}

