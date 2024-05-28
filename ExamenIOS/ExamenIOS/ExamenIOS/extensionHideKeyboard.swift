import Foundation
import SwiftUI


extension View {
    func hideKeyboardWhenTappedAround() -> some View {
        return self.onTapGesture {
            self.endEditing(true)
        }
    }

    private func endEditing(_ force: Bool) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
