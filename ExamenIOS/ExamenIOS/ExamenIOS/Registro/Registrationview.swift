import SwiftUI

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Información Personal")) {
                    TextField("Nombre", text: $viewModel.registrationData.name)
                    if let error = viewModel.formErrors["name"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    TextField("Apellidos", text: $viewModel.registrationData.lastName)
                    if let error = viewModel.formErrors["lastName"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    DatePicker(
                        "Fecha de Nacimiento",
                        selection: Binding(
                            get: { self.viewModel.registrationData.birthDate ?? Date() },
                            set: { self.viewModel.registrationData.birthDate = $0 }
                        ),
                        displayedComponents: .date
                    ).onChange(of: viewModel.registrationData.birthDate) { newDate in
                        if let newDate = newDate {
                            viewModel.checkAge(date: newDate)
                        }
                    }
                    if let error = viewModel.formErrors["birthDate"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    Picker("Sexo", selection: $viewModel.registrationData.gender) {
                        Text("Masculino").tag("Masculino")
                        Text("Femenino").tag("Femenino")
                    }.pickerStyle(SegmentedPickerStyle())
                    if let error = viewModel.formErrors["gender"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }

                Section(header: Text("Credenciales de Acceso")) {
                    TextField("Correo Electrónico", text: $viewModel.registrationData.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.emailAddress)
                        .onChange(of: viewModel.registrationData.email) { newEmail in
                            viewModel.checkIfEmailExists(email: newEmail.lowercased())
                        }
                    if let error = viewModel.formErrors["email"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                    if viewModel.emailAlreadyRegistered {
                        Text("Este correo ya está registrado").foregroundColor(.red).font(.caption)
                    }

                    HStack {
                        if viewModel.showPassword {
                            TextField("Contraseña", text: $viewModel.registrationData.password)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Contraseña", text: $viewModel.registrationData.password)
                        }
                        Button(action: {
                            viewModel.showPassword.toggle()
                        }) {
                            Image(systemName: viewModel.showPassword ? "eye.slash" : "eye")
                        }
                    }
                    if let error = viewModel.formErrors["password"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }

                    HStack {
                        if viewModel.showConfirmPassword {
                            TextField("Confirmar Contraseña", text: $viewModel.registrationData.confirmPassword)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Confirmar Contraseña", text: $viewModel.registrationData.confirmPassword)
                        }
                        Button(action: {
                            viewModel.showConfirmPassword.toggle()
                        }) {
                            Image(systemName: viewModel.showConfirmPassword ? "eye.slash" : "eye")
                        }
                    }
                    if let error = viewModel.formErrors["confirmPassword"] {
                        Text(error).foregroundColor(.red).font(.caption)
                    }
                }

                Button("Crear Usuario") {
                    viewModel.validateAndCreateUser()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(viewModel.allFieldsFilled && !viewModel.emailAlreadyRegistered ? Color.blue : Color.gray)
                .cornerRadius(8)
                .disabled(viewModel.emailAlreadyRegistered)

                VStack(alignment: .leading) {
                    Text("Al darle al botón crear usuario aceptas nuestros ")
                        .foregroundColor(.primary)
                        .font(.system(size: 11))
                        .lineLimit(1)

                    HStack {
                        Button("Términos y Condiciones") {
                            viewModel.showTermsSheet.toggle()
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                        .lineLimit(1)
                        .sheet(isPresented: $viewModel.showTermsSheet) {
                            TerminosView()
                        }

                        Text("y nuestra política de privacidad.")
                            .foregroundColor(.primary)
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .navigationTitle("Registro")
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Registro"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        if viewModel.shouldNavigateToLogin {
                            viewModel.shouldNavigateToLogin = true
                        }
                    })
                )
            }
            .background(
                NavigationLink(destination: LoginView(), isActive: $viewModel.shouldNavigateToLogin) { EmptyView() }
            )
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RegistrationView()
                .preferredColorScheme(.dark)
            RegistrationView()
                .preferredColorScheme(.light)
        }
    }
}

