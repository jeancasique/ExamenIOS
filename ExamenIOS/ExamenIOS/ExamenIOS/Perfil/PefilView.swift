import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import LocalAuthentication
import AuthenticationServices
import Kingfisher

class UserData: ObservableObject {
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthDate: Date = Date()
    @Published var gender: String = ""
    @Published var profileImage: UIImage?
    @Published var profileImageURL: String? = nil // Cambiar a opcional
}

struct PerfilView: View {
    @StateObject private var userData = UserData()
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
                        Text(userData.firstName)
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
                            
                            Text(userData.email)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.trailing, 8)
                        }
                        .padding(.vertical, 1)
                        
                        VStack(alignment: .leading) {
                            userInfoField(label: "Nombre", value: $userData.firstName, editing: $editingField, fieldKey: "firstName", editable: true)
                            userInfoField(label: "Apellidos", value: $userData.lastName, editing: $editingField, fieldKey: "lastName", editable: true)
                            datePickerField(label: "Fecha de Nacimiento:", date: $userData.birthDate, editing: $editingField, fieldKey: "birthDate")
                            genderPickerField(label: "Género", value: $userData.gender, editing: $editingField, fieldKey: "gender")
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
                .onAppear(perform: loadUserData)
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
            
            if let urlString = userData.profileImageURL, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .foregroundColor(.white)
                    }
                    .cancelOnDisappear(true)
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

    func userInfoField(label: String, value: Binding<String>, editing: Binding<String?>, fieldKey: String, editable: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .fontWeight(.bold)
            
            HStack {
                if editing.wrappedValue == fieldKey {
                    TextField("", text: value)
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

    func saveData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let profileImage = userData.profileImage {
            saveProfileImage(userId: userId, image: profileImage)
        }
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": self.userData.email,
            "firstName": self.userData.firstName,
            "lastName": self.userData.lastName,
            "birthDate": DateFormatter.iso8601Full.string(from: self.userData.birthDate),
            "gender": self.userData.gender,
            "profileImageURL": self.userData.profileImageURL ?? "" // Usar el valor opcional correctamente
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error updating user data: \(error.localizedDescription)")
            } else {
                print("User data updated successfully")
                self.showAlert = true
                self.alertMessage = "Datos guardados correctamente"
                if let profileImageURL = self.userData.profileImageURL {
                    DataManager.shared.cacheProfileImageURL(profileImageURL) // Cachear URL de imagen
                }
            }
        }
    }

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
                            DataManager.shared.cacheProfileImageURL(imageUrl.absoluteString)
                        }
                    }
                }.resume()
            } else {
                print("No se encontró la URL de la imagen de perfil de Google")
            }
        }
    }
    
    func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
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
                }
            } else {
                self.loadUserDataFromApple()
            }
        }
    }

    func loadUserDataFromApple() {
        if userData.profileImage == nil {
            guard let user = Auth.auth().currentUser else {
                print("No hay usuario autenticado")
                return
            }
            
            userData.email = user.email ?? ""
            userData.firstName = user.displayName?.components(separatedBy: " ").first ?? ""
            userData.lastName = user.displayName?.components(separatedBy: " ").last ?? ""
        }
    }

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
    }

    func loadProfileImageFromURL() {
        guard let urlString = userData.profileImageURL, let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to download image data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.userData.profileImage = image
                }
            }
        }.resume()
    }

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
                    DataManager.shared.cacheProfileImageURL(downloadURL.absoluteString)
                }
            }
        }
    }

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

struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
    }
}

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

