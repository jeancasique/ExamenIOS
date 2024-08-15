
import SwiftUI

class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: String = ""
    @Published var profileImage: UIImage?
    @Published var profileImageURL: String? = nil
}
