import SwiftUI

struct PasswordResetView: View {
    @StateObject private var viewModel = PasswordResetViewModel() // Inicializar el ViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            if colorScheme == .dark {
                Image("logoDark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
            } else {
                Image("lock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 10)
            }

            Text("Se enviará un correo electrónico para restablecer tu contraseña.")
                .font(.caption)
                .padding(.vertical, 8)

            TextField("Correo Electrónico", text: $viewModel.email)
                .padding()
                .padding(.horizontal, 20)
                .overlay(HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    Spacer()
                })
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disableAutocorrection(true)
                .border(Color(UIColor.separator))
                .padding(.vertical, 20)
                .accessibilityLabel("Correo electrónico")
                .accessibilityHint("Introduce tu correo electrónico para restablecer la contraseña")

            if !viewModel.emailError.isEmpty {
                Text(viewModel.emailError)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Restablecer Contraseña") {
                if viewModel.email.isEmpty {
                    viewModel.emailError = "Por favor, introduce un correo electrónico."
                } else {
                    viewModel.sendPasswordResetEmail()
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(viewModel.emailError.isEmpty ? Color.blue : Color.gray)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .background(colorScheme == .dark ? Color.black : Color.white)
        .navigationTitle("Restablecer Contraseña")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink("", destination: LoginView(), isActive: $viewModel.shouldNavigateToLogin) // NavigationLink oculto
        )
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PasswordResetView()
                .preferredColorScheme(.dark)
            
            PasswordResetView()
                .preferredColorScheme(.light)
        }
    }
}

