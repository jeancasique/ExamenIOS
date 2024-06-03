import SwiftUI
import FacebookCore
import FacebookLogin
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore
import AuthenticationServices

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme

    init(session: SessionStore) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(session: session))
    }

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
                    viewModel.session.listen()
                }
                .navigationDestination(isPresented: $viewModel.isUserLoggedIn) {
                    MoviesView()
                        .environmentObject(viewModel.session.userData)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
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
                viewModel.authenticateWithFaceID { success, email, password in
                    if success {
                        viewModel.email = email ?? ""
                        viewModel.password = password ?? ""
                        viewModel.validateFields()
                    }
                }
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Inicia Sesión con Face ID")
                }
                .padding(8)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    viewModel.performGoogleSignIn { success in
                        if success {
                            viewModel.session.isLoggedIn = true
                        }
                    }
                }) {
                    Image("googleLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(colorScheme == .dark ? Color.clear : Color.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    viewModel.performAppleSignIn { fullName, email in
                        if let fullName = fullName, let email = email {
                            let (firstName, lastName) = viewModel.splitFullName(fullName)
                            viewModel.saveAppleCredentialsToFirestore(firstName: firstName, lastName: lastName, email: email)
                            viewModel.session.isLoggedIn = true
                        }
                    }
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
                    .environmentObject(viewModel.session)
            }
            .padding(2)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView(session: SessionStore())
                .preferredColorScheme(.dark)
                .environmentObject(SessionStore())
            LoginView(session: SessionStore())
                .preferredColorScheme(.light)
                .environmentObject(SessionStore())
        }
    }
}

