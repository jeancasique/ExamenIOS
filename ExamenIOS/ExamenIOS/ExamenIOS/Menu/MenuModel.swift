import SwiftUI

struct MenuItem: View {
    var icon: String
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
        }
    }
}

