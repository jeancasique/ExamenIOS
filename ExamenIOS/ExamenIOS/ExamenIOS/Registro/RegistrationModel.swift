import Foundation

struct RegistrationModel {
    var name: String = ""
    var lastName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var birthDate: Date? = nil
    var gender: String = ""
    
    // Este inicializador es opcional si estás utilizando valores por defecto
    init(name: String = "", lastName: String = "", email: String = "", password: String = "", confirmPassword: String = "", birthDate: Date? = nil, gender: String = "") {
        self.name = name
        self.lastName = lastName
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
        self.birthDate = birthDate
        self.gender = gender
    }
}

