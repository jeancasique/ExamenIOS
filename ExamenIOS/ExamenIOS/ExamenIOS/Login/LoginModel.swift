
import Foundation

struct User {
    var uid: String
    var email: String
    var password: String
}

enum AuthenticationError: Error, LocalizedError {
    case invalidEmail
    case invalidPassword
    case authenticationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Introduce un correo electrónico válido."
        case .invalidPassword:
            return "La contraseña debe tener al menos 5 caracteres, una mayúscula y un número."
        case .authenticationFailed(let message):
            return message
        }
    }
}

