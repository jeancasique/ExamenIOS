import SwiftUI
import Combine
import Firebase
import FirebaseStorage

class PerfilViewModel: ObservableObject {
    @Published var userData: UserData
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    init(userData: UserData) {
        self.userData = userData
    }

    func loadUserData() {
        let db = Firestore.firestore()
        db.collection("users").document("userId").getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData.firstName = data?["firstName"] as? String ?? ""
                    self.userData.lastName = data?["lastName"] as? String ?? ""
                    self.userData.email = data?["email"] as? String ?? ""
                    self.userData.profileImageURL = data?["profileImageURL"] as? String
                    self.userData.birthDate = (data?["birthDate"] as? Timestamp)?.dateValue() ?? Date()
                    self.userData.gender = data?["gender"] as? String ?? ""
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    func saveUserData() {
        let db = Firestore.firestore()
        db.collection("users").document("userId").setData([
            "firstName": userData.firstName,
            "lastName": userData.lastName,
            "email": userData.email,
            "profileImageURL": userData.profileImageURL ?? "",
            "birthDate": Timestamp(date: userData.birthDate),
            "gender": userData.gender
        ]) { error in
            if let error = error {
                print("Error saving user data: \(error)")
            } else {
                print("User data saved successfully")
            }
        }
    }

    func saveProfileImage(image: UIImage, completion: @escaping (Bool) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(UUID().uuidString).jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            let uploadTask = storageRef.putData(imageData, metadata: nil) { [weak self] metadata, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error uploading image: \(error)")
                    completion(false)
                } else {
                    storageRef.downloadURL { [weak self] url, error in
                        guard let self = self else { return }
                        if let url = url {
                            DispatchQueue.main.async {
                                self.userData.profileImageURL = url.absoluteString
                            }
                            self.saveUserData() // Update user data with new profile image URL
                            completion(true)
                        } else {
                            print("Error getting download URL: \(error?.localizedDescription ?? "No error description")")
                            completion(false)
                        }
                    }
                }
            }
        } else {
            completion(false)
        }
    }

    func updateField(_ key: String, value: String) {
        switch key {
        case "firstName":
            userData.firstName = value
        case "lastName":
            userData.lastName = value
        case "gender":
            userData.gender = value
        default:
            break
        }
    }

    func updateBirthDate(_ date: Date) {
        userData.birthDate = date
    }

    func updateGender(_ gender: String) {
        userData.gender = gender
    }
}


extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}
