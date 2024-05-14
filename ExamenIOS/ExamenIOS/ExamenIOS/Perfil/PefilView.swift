import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import LocalAuthentication
import AuthenticationServices
import Kingfisher

// Clase para gestionar los datos del usuario utilizando el patrón ObservableObject
class UserData: ObservableObject {
    @Published var email: String = ""                   // Correo electrónico del usuario
    @Published var firstName: String = ""               // Nombre del usuario
    @Published var lastName: String = ""                // Apellidos del usuario
    @Published var birthDate: Date = Date()             // Fecha de nacimiento del usuario
    @Published var gender: String = ""                  // Género del usuario
    @Published var profileImage: UIImage?               // Imagen de perfil del usuario
    @Published var profileImageURL: String = ""         // URL de la imagen de perfil del usuario
}

// Vista principal de perfil del usuario
struct PerfilView: View {
    @StateObject private var userData = UserData() // Datos del usuario como objeto de estado
    
    // Estados para controlar la edición y visualización de la vista
    @State private var editingField: String? = nil
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var sourceType: UIImagePickerController.SourceType? = nil
    @State private var showDocumentPicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                ZStack(alignment: .top) {
                    // Fondo gris en la parte superior de la pantalla
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: UIScreen.main.bounds.height * 0.185)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack(alignment: .center, spacing: 20) {
                        // Mostrar el nombre del usuario
                        Text(userData.firstName)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        // Sección para la imagen de perfil
                        profileImageSection
                            .padding(.top, 20)
                        
                        // Mostrar el correo electrónico del usuario
                        VStack(alignment: .leading) {
                            Text("Email")
                                .padding(.vertical, 1)
                                .font(.body)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer(minLength: 8)
                            
                            Text(userData.email)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        .padding(.vertical, 1)
                        
                        // Sección de información del usuario
                        VStack(alignment: .leading) {
                            userInfoField(label: "Nombre", value: $userData.firstName, editing: $editingField, fieldKey: "firstName", editable: true)
                            userInfoField(label: "Apellidos", value: $userData.lastName, editing: $editingField, fieldKey: "lastName", editable: true)
                            datePickerField(label: "Fecha de Nacimiento:", date: $userData.birthDate, editing: $editingField, fieldKey: "birthDate")
                            genderPickerField(label: "Género", value: $userData.gender, editing: $editingField, fieldKey: "gender")
                        }
                        
                        // Botón para guardar cambios
                        Button("Guardar Cambios", action: saveData)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear(perform: loadUserData) // Cargar los datos del usuario al aparecer la vista
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $userData.profileImage)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Datos Guardados"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
    
    // Sección que muestra y gestiona la imagen de perfil
    var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 140, height: 140)
                .shadow(radius: 10)
            
            if let image = userData.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .onTapGesture {
            self.showActionSheet = true
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Selecciona una opción"), buttons: [
                .default(Text("Abrir Galería")) {
                    self.showImagePicker = true
                    self.sourceType = .photoLibrary
                },
                .default(Text("Tomar Foto")) {
                    self.showImagePicker = true
                    self.sourceType = .camera
                },
                .default(Text("Seleccionar Archivo")) {
                    self.showDocumentPicker = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $userData.profileImage, sourceType: sourceType!)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(image: $userData.profileImage)
        }
    }

    // Función para generar campos de usuario editables
    func userInfoField(label: String, value: Binding<String>, editing: Binding<String?>, fieldKey: String, editable: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.bold)
            
            HStack {
                if editing.wrappedValue == fieldKey {
                    TextField("", text: value) // Usando el texto vacío para el placeholder
                        .background(.blue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .cornerRadius(5)
                    
                    Button(action: { editing.wrappedValue = nil }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                } else {
                    Text(value.wrappedValue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if editable {
                        Button(action: { editing.wrappedValue = fieldKey }) {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    // Función para generar un selector de fechas con consistencia en el diseño
    func datePickerField(label: String, date: Binding<Date>, editing: Binding<String?>, fieldKey: String) -> some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            
            if editing.wrappedValue == fieldKey {
                DatePicker("", selection: date, displayedComponents: [.date])
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .padding(.horizontal)
                Button(action: { editing.wrappedValue = nil }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else {
                Text("\(date.wrappedValue, formatter: DateFormatter.iso8601Full)")
                    .padding(.horizontal)
                Spacer()
                Button(action: { editing.wrappedValue = fieldKey }) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
    // Función para generar un campo de selección de género con consistencia en el diseño
       func genderPickerField(label: String, value: Binding<String>, editing: Binding<String?>, fieldKey: String) -> some View {
           VStack(alignment: .leading) {
               Text(label)
                   .fontWeight(.bold)
               
               HStack {
                   if editing.wrappedValue == fieldKey {
                       Picker(selection: value, label: Text("")) {
                           Text("Masculino").tag("Masculino")
                           Text("Femenino").tag("Femenino")
                       }
                       .pickerStyle(SegmentedPickerStyle())
                       .background(Color.gray)
                       .cornerRadius(5)
                       
                       Button(action: { editing.wrappedValue = nil }) {
                           Image(systemName: "checkmark.circle.fill")
                               .foregroundColor(.green)
                       }
                   } else {
                       Text(value.wrappedValue)
                           .frame(maxWidth: .infinity, alignment: .leading)
                       
                       Button(action: { editing.wrappedValue = fieldKey }) {
                           Image(systemName: "pencil.circle.fill")
                               .foregroundColor(.blue)
                       }
                       .buttonStyle(BorderlessButtonStyle())
                   }
               }
           }
           .padding(.vertical, 8)
       }
    // Función para guardar los cambios realizados a los datos del usuario
    func saveData() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica si hay un usuario autenticado
        
        if let profileImage = userData.profileImage {
            saveProfileImage(userId: userId, image: profileImage) // Guarda la imagen de perfil si está disponible
        }
        
        let db = Firestore.firestore() // Obtiene una instancia de Firestore
        let userData = [
            "email": self.userData.email,
            "firstName": self.userData.firstName,
            "lastName": self.userData.lastName,
            "birthDate": DateFormatter.iso8601Full.string(from: self.userData.birthDate),
            "gender": self.userData.gender,
            "profileImageURL": self.userData.profileImageURL
        ]
        
        // Guarda los datos del usuario en Firestore
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                print("User data updated successfully")
                self.showAlert = true
                self.alertMessage = "Datos guardados correctamente"
                PerfilData.shared.saveUserData(userData: self.userData) // Guarda los datos en caché
            }
        }
    }

    // Función para cargar la imagen de perfil desde Google
    func loadImageFromGoogle() {
        if userData.profileImage == nil {
            guard let user = Auth.auth().currentUser else {
                print("No hay usuario autenticado")
                return
            }
            
            if let imageUrl = user.photoURL {
                URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Failed to download image data:", error?.localizedDescription ?? "Unknown error")
                        return
                    }
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            self.userData.profileImage = image
                            self.saveProfileImage(userId: user.uid, image: image)
                            PerfilData.shared.cacheProfileImage(urlString: imageUrl.absoluteString)
                        }
                    }
                }.resume()
            } else {
                print("No se encontró la URL de la imagen de perfil de Google")
            }
        }
    }
    
    // Función para cargar los datos del usuario desde Firestore
    func loadUserData() {
        let cachedData = PerfilData.shared.loadUserData() // Carga los datos desde la caché
        self.userData.email = cachedData.email
        self.userData.firstName = cachedData.firstName
        self.userData.lastName = cachedData.lastName
        self.userData.birthDate = cachedData.birthDate
        self.userData.gender = cachedData.gender
        self.userData.profileImageURL = cachedData.profileImageURL
        
        // Carga la imagen de perfil desde la caché
        PerfilData.shared.loadProfileImage(urlString: cachedData.profileImageURL) { image in
            if let image = image {
                self.userData.profileImage = image
            }
        }
        
        guard let userId = Auth.auth().currentUser?.uid else { return } // Verifica si hay un usuario autenticado
        
        let db = Firestore.firestore() // Obtiene una instancia de Firestore
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData.email = data?["email"] as? String ?? ""
                    self.userData.firstName = data?["firstName"] as? String ?? ""
                    self.userData.lastName = data?["lastName"] as? String ?? ""
                    self.userData.gender = data?["gender"] as? String ?? ""
                    
                    if let birthDate = data?["birthDate"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        if let date = dateFormatter.date(from: birthDate) {
                            self.userData.birthDate = date
                        } else {
                            print("Error: No se pudo convertir la fecha de nacimiento a Date")
                        }
                    } else {
                        print("Advertencia: No se encontró la fecha de nacimiento en el documento")
                    }
                    
                    if let profileImageURL = data?["profileImageURL"] as? String {
                        self.userData.profileImageURL = profileImageURL
                        self.loadProfileImageFromURL()
                    } else {
                        self.loadImageFromGoogle()
                    }
                    
                    PerfilData.shared.saveUserData(userData: self.userData) // Guarda los datos en caché
                }
            } else {
                self.loadUserDataFromApple()
            }
        }
    }

    // Función para cargar los datos del usuario desde Apple
    func loadUserDataFromApple() {
        if userData.profileImage == nil {
            guard let user = Auth.auth().currentUser else {
                print("No hay usuario autenticado")
                return
            }
            
            userData.email = user.email ?? ""
            userData.firstName = user.displayName?.components(separatedBy: " ").first ?? ""
            userData.lastName = user.displayName?.components(separatedBy: " ").last ?? ""
            
            DispatchQueue.main.async {
                PerfilData.shared.saveUserData(userData: self.userData) // Guarda los datos en caché
            }
        }
    }

    // Función para actualizar los datos del usuario en el objeto UserData y en la vista
    func updateUserData(with data: [String: Any]?) {
        guard let data = data else { return }
        self.userData.email = data["email"] as? String ?? ""
        self.userData.firstName = data["firstName"] as? String ?? ""
        self.userData.lastName = data["lastName"] as? String ?? ""
        self.userData.gender = data["gender"] as? String ?? ""
        
        if let birthDateTimestamp = data["birthDate"] as? Timestamp {
            self.userData.birthDate = birthDateTimestamp.dateValue()
        }
        
        if let profileImageURL = data["profileImageURL"] as? String {
            self.userData.profileImageURL = profileImageURL
            self.loadProfileImageFromURL()
        } else {
            self.loadUserDataFromApple()
        }
        
        PerfilData.shared.saveUserData(userData: self.userData) // Guarda los datos en caché
    }

    // Función para cargar la imagen de perfil desde una URL
    func loadProfileImageFromURL() {
        PerfilData.shared.loadProfileImage(urlString: userData.profileImageURL) { image in
            if let image = image {
                self.userData.profileImage = image
            }
        }
    }

    // Función para guardar la imagen de perfil en Firebase Storage y obtener la URL de descarga
    func saveProfileImage(userId: String, image: UIImage) {
        let resizedImage = image.resized(to: CGSize(width: 300, height: 300))
        
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
            print("Failed to convert image to JPEG data")
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata, error == nil else {
                print("Error uploading profile image:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Error fetching download URL:", error?.localizedDescription ?? "Unknown error")
                    return
                }
                
                DispatchQueue.main.async {
                    self.userData.profileImageURL = downloadURL.absoluteString
                    self.updateProfileImageURLInFirestore(userId: userId, imageUrl: downloadURL.absoluteString)
                    PerfilData.shared.cacheProfileImage(urlString: downloadURL.absoluteString)
                }
            }
        }
    }

    // Función para actualizar la URL de la imagen de perfil en Firestore
    func updateProfileImageURLInFirestore(userId: String, imageUrl: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(["profileImageURL": imageUrl]) { error in
            if let error = error {
                print("Error updating image URL in Firestore:", error.localizedDescription)
            } else {
                print("Image URL successfully updated in Firestore")
            }
        }
    }
}

// Vista de previsualización para SwiftUI
struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
    }
}

// Extensión de DateFormatter para usar el formato ISO8601 completo
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// Extensión de UIImage para redimensionar imágenes
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

