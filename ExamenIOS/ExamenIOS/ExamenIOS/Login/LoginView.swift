import SwiftUI
import FacebookLogin

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var session: SessionStore
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    emailField
                    passwordField
                    actionButtons
                    Spacer()
                }
                .foregroundColor(.primary)
                .padding()
                .navigationTitle("Iniciar Sesión")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EmptyView()
                    }
                }
                .onAppear {
                    session.listen()
                }
                .navigationDestination(isPresented: $viewModel.isUserLoggedIn) {
                    MoviesView()
                        .environmentObject(UserData()) // Asegúrate de proporcionar el UserData adecuado
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
        .preferredColorScheme(.dark) // Configura el tema oscuro para LoginView
    }

    private var emailField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                TextField("Correo Electrónico", text: $viewModel.email)
                    .padding(.vertical, 20)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .disableAutocorrection(true)
            }
            .border(Color(UIColor.separator))
            .padding(.horizontal, 8)
            .padding(.vertical, 20)
            .onChange(of: viewModel.email, perform: viewModel.validateEmail)
            .submitLabel(.next)

            if !viewModel.emailError.isEmpty {
                Text(viewModel.emailError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding([.horizontal, .top], 4)
            }
        }
    }

    private var passwordField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                SecureField("Contraseña", text: $viewModel.password)
                    .padding(.vertical, 20)
            }
            .border(Color(UIColor.separator))
            .padding(.horizontal, 8)
            .padding(.vertical, 20)
            .onChange(of: viewModel.password, perform: viewModel.validatePassword)
            .submitLabel(.done)

            if !viewModel.passwordError.isEmpty {
                Text(viewModel.passwordError)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding([.horizontal, .top], 4)
            }
        }
    }

    private var actionButtons: some View {
        VStack {
            HStack(spacing: 60) {
                Button("Iniciar Sesión") {
                    viewModel.validateFields()
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)

                NavigationLink("Registro", destination: RegistrationView())
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding()

            NavigationLink(destination: PasswordResetView()) {
                Text("¿Olvidaste tu contraseña?")
                    .foregroundColor(.blue)
            }

            Button(action: {
                viewModel.signInWithFaceID()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Inicia Sesión con Face ID")
                }
                .padding(8)
            }

            HStack(spacing: 20) {
                Button(action: {
                    viewModel.signInWithGoogle()
                }) {
                    Image("googleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.clear : Color.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.signInWithApple()
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .cornerRadius(8)
                }

                FacebookLoginButton()
                    .frame(width: 60, height: 60)
                    .padding(8)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                    .environmentObject(session) // Asegúrate de pasar session como un environmentObject
            }
            .padding(2)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .preferredColorScheme(.dark)
                .environmentObject(SessionStore())
            LoginView()
                .preferredColorScheme(.light)
                .environmentObject(SessionStore())
        }
    }
}

