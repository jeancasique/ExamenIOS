import SwiftUI
import Kingfisher

struct PerfilView: View {
    @EnvironmentObject var viewModel: PerfilViewModel
    @State private var editingField: String? = nil
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var sourceType: UIImagePickerController.SourceType? = nil
    @State private var showDocumentPicker = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            ScrollView {
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: UIScreen.main.bounds.height * 0.185)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text(viewModel.userData.firstName)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        profileImageSection
                            .padding(.top, 20)
                        
                        VStack(alignment: .leading) {
                            Text("Email")
                                .padding(.vertical, 1)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer(minLength: 8)
                            
                            Text(viewModel.userData.email)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        .padding(.vertical, 1)
                        
                        VStack(alignment: .leading) {
                            userInfoField(label: "Nombre", value: $viewModel.userData.firstName, editing: $editingField, fieldKey: "firstName", editable: true)
                            userInfoField(label: "Apellidos", value: $viewModel.userData.lastName, editing: $editingField, fieldKey: "lastName", editable: true)
                            datePickerField(label: "Fecha de Nacimiento:", date: $viewModel.userData.birthDate, editing: $editingField, fieldKey: "birthDate")
                            genderPickerField(label: "Género", value: $viewModel.userData.gender)
                        }
                        
                        Button("Guardar Cambios", action: saveData)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear(perform: viewModel.loadUserData)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $viewModel.userData.profileImage, sourceType: sourceType!)
                        .onDisappear {
                            if let profileImage = viewModel.userData.profileImage {
                                viewModel.saveProfileImage(image: profileImage) { success in
                                    if success {
                                        viewModel.userData.profileImage = profileImage
                                    } else {
                                        print("Failed to save profile image")
                                    }
                                }
                            }
                        }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Datos Guardados"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            })
        }
        .navigationBarBackButtonHidden(true)
    }
    
    var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 140, height: 140)
                .shadow(radius: 10)
            
            if let profileImage = viewModel.userData.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else if let profileImageURL = viewModel.userData.profileImageURL, let url = URL(string: profileImageURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .foregroundColor(.white)
                    }
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            showActionSheet = true
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Selecciona una fuente"),
                buttons: [
                    .default(Text("Tomar foto")) {
                        sourceType = .camera
                        showImagePicker = true
                    },
                    .default(Text("Elegir de la galería")) {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .default(Text("Elegir desde archivos")) {
                        showDocumentPicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(image: $viewModel.userData.profileImage)
        }
    }
    
    func userInfoField(label: String, value: Binding<String>, editing: Binding<String?>, fieldKey: String, editable: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .padding(.vertical, 1)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer(minLength: 8)
            
            HStack {
                if editable && editing.wrappedValue == fieldKey {
                    TextField(label, text: value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .background(Color.blue)
                        .foregroundColor(.white)
                } else {
                    Text(value.wrappedValue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                if editable {
                    Image(systemName: editing.wrappedValue == fieldKey ? "pencil.circle.fill" : "pencil.circle")
                        .foregroundColor(editing.wrappedValue == fieldKey ? .red : .blue)
                        .onTapGesture {
                            if editing.wrappedValue == fieldKey {
                                editing.wrappedValue = nil
                            } else {
                                editing.wrappedValue = fieldKey
                            }
                        }
                }
            }
        }
        .padding(.vertical, 1)
    }
    
    func datePickerField(label: String, date: Binding<Date>, editing: Binding<String?>, fieldKey: String) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .padding(.vertical, 1)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer(minLength: 8)
            
            HStack {
                if editing.wrappedValue == fieldKey {
                    DatePicker("", selection: date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .background(Color.blue)
                        .foregroundColor(.white)
                } else {
                    Text(date.wrappedValue, style: .date)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.body)
                        .foregroundColor(.primary)
                }
                
                Image(systemName: editing.wrappedValue == fieldKey ? "pencil.circle.fill" : "pencil.circle")
                    .foregroundColor(editing.wrappedValue == fieldKey ? .red : .blue)
                    .onTapGesture {
                        if editing.wrappedValue == fieldKey {
                            editing.wrappedValue = nil
                        } else {
                            editing.wrappedValue = fieldKey
                        }
                    }
            }
        }
        .padding(.vertical, 1)
    }
    
    func genderPickerField(label: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .padding(.vertical, 1)
                .font(.body)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer(minLength: 8)
            
            Picker("Género", selection: value) {
                Text("Masculino").tag("Masculino")
                Text("Femenino").tag("Femenino")
                Text("Otro").tag("Otro")
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(Color.blue)
            .cornerRadius(8)
            .foregroundColor(.white)
        }
        .padding(.vertical, 1)
    }
    
    func saveData() {
        viewModel.saveUserData()
        alertMessage = "Todos los cambios se han guardado con éxito."
        showAlert = true
    }
}

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        // Inicializa el PerfilViewModel con datos simulados
        let viewModel = PerfilViewModel(userData: UserData())
        viewModel.userData = UserData()
        
        return PerfilView()
            .environmentObject(viewModel) // Proporciona el PerfilViewModel como EnvironmentObject
    }
}

