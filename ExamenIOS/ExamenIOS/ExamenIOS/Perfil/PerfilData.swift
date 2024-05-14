import Foundation
import SwiftUI
import Kingfisher

class PerfilData {
    static let shared = PerfilData()
    
    private let userDefaults = UserDefaults.standard

    // Claves para UserDefaults
    private let emailKey = "email"
    private let firstNameKey = "firstName"
    private let lastNameKey = "lastName"
    private let birthDateKey = "birthDate"
    private let genderKey = "gender"
    private let profileImageURLKey = "profileImageURL"

    // Función para guardar los datos del usuario en caché
    func saveUserData(userData: UserData) {
        userDefaults.setValue(userData.email, forKey: emailKey)
        userDefaults.setValue(userData.firstName, forKey: firstNameKey)
        userDefaults.setValue(userData.lastName, forKey: lastNameKey)
        userDefaults.setValue(DateFormatter.iso8601Full.string(from: userData.birthDate), forKey: birthDateKey)
        userDefaults.setValue(userData.gender, forKey: genderKey)
        userDefaults.setValue(userData.profileImageURL, forKey: profileImageURLKey)
    }

    // Función para cargar los datos del usuario desde la caché
    func loadUserData() -> UserData {
        let userData = UserData()
        userData.email = userDefaults.string(forKey: emailKey) ?? ""
        userData.firstName = userDefaults.string(forKey: firstNameKey) ?? ""
        userData.lastName = userDefaults.string(forKey: lastNameKey) ?? ""
        if let birthDateString = userDefaults.string(forKey: birthDateKey), let birthDate = DateFormatter.iso8601Full.date(from: birthDateString) {
            userData.birthDate = birthDate
        }
        userData.gender = userDefaults.string(forKey: genderKey) ?? ""
        userData.profileImageURL = userDefaults.string(forKey: profileImageURLKey) ?? ""
        return userData
    }

    // Función para guardar la imagen de perfil en caché con KingFisher
    func cacheProfileImage(urlString: String) {
        if let url = URL(string: urlString) {
            let cache = ImageCache.default
            cache.retrieveImage(forKey: urlString) { result in
                switch result {
                case .success(let value):
                    if value.image == nil {
                        let processor = DownsamplingImageProcessor(size: CGSize(width: 300, height: 300))
                        KingfisherManager.shared.retrieveImage(with: url, options: [.processor(processor), .cacheOriginalImage]) { result in
                            switch result {
                            case .success(let value):
                                cache.store(value.image, forKey: urlString)
                            case .failure(let error):
                                print("Error caching image: \(error)")
                            }
                        }
                    }
                case .failure(let error):
                    print("Error retrieving cached image: \(error)")
                }
            }
        }
    }

    // Función para cargar la imagen de perfil desde la caché
    func loadProfileImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    completion(value.image)
                case .failure(let error):
                    print("Error loading cached image: \(error)")
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
}
