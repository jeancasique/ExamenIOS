import Foundation
import FirebaseAuth
import FirebaseFirestore

class PasswordResetModel {
    func checkIfEmailExists(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let lowercasedEmail = email.lowercased()
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: lowercasedEmail).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else if snapshot?.documents.isEmpty == true {
                completion(.success(false))
            } else {
                completion(.success(true))
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
