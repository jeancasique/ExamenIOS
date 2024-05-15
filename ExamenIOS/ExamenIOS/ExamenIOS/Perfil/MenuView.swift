import SwiftUI
import FirebaseAuth
import Kingfisher

struct MenuView: View {
    @Binding var isOpen: Bool // Binding para controlar si el menú está abierto
    @State private var showProfile = false // Estado para mostrar la vista de perfil
    @State private var showFavorites = false // Estado para mostrar la vista de favoritos
    @State private var showSettings = false // Estado para mostrar la vista de ajustes
    @State private var showHome = false // Estado para mostrar la vista de home (MoviesView)
    @State private var isLoggedOut = false // Estado para manejar la redirección al logout
    
    @EnvironmentObject var session: SessionStore // Estado de sesión
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Contenedor principal del menú
            VStack(alignment: .leading, spacing: 20) {
                // Foto de perfil y nombre de usuario
                VStack(alignment: .center) {
                    profileImageSection // Imagen de perfil del usuario
                    
                    Text(session.userData?.firstName.isEmpty ?? true ? "Hola, usuario!" : "Hola \(session.userData?.firstName ?? "")") // Nombre del usuario
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary) // Cambia el color para ser compatible con el modo oscuro
                        .lineLimit(1)
                    
                    Text("UX/UI Designer") // Descripción del usuario
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                .padding(.horizontal, 50)
                .padding(.bottom, 10)
                
                Divider() // Línea divisoria
                
                // Opciones del menú
                Group {
                    MenuItem(icon: "house.fill", text: "Home") {
                        self.showHome = true // Acción para mostrar la vista de home (MoviesView)
                    }
                    MenuItem(icon: "person.fill", text: "Perfil") {
                        self.showProfile = true // Acción para mostrar la vista de perfil
                    }
                    MenuItem(icon: "bookmark.fill", text: "Favoritos") {
                        self.showFavorites = true // Acción para mostrar la vista de favoritos
                    }
                    MenuItem(icon: "gearshape.fill", text: "Ajustes") {
                        self.showSettings = true // Acción para mostrar la vista de ajustes
                    }
                }
                .padding(.horizontal)
                
                Spacer() // Espacio flexible para empujar los elementos hacia arriba
                
                Divider() // Línea divisoria
                
                // Opción de logout
                MenuItem(icon: "arrowshape.turn.up.left.fill", text: "Logout") {
                    logout() // Acción para cerrar sesión
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground)) // Fondo del menú, compatible con modo oscuro
            .frame(width: UIScreen.main.bounds.width * 0.7) // 70% del ancho de la pantalla
            .shadow(radius: 20) // Sombra para dar efecto de profundidad
        }
        // Presentación de vistas en pantalla completa cuando se seleccionan las opciones del menú
        .fullScreenCover(isPresented: $showHome) {
            NavigationView {
                MoviesView() // Vista de home (MoviesView)
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false) // Mostrar el botón de retroceso
            }
        }
        .fullScreenCover(isPresented: $showProfile) {
            NavigationView {
                PerfilView() // Vista de perfil
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false) // Mostrar el botón de retroceso
            }
        }
        .fullScreenCover(isPresented: $showFavorites) {
            NavigationView {
                FavoritesMovies() // Vista de favoritos
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false) // Mostrar el botón de retroceso
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            NavigationView {
                Ajustes() // Vista de ajustes
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false) // Mostrar el botón de retroceso
            }
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView() // Vista de Login
                .environmentObject(session)
        }
    }

    // Sección que muestra y gestiona la imagen de perfil
    var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 140, height: 140)
                .shadow(radius: 10)
            
            if let urlString = session.userData?.profileImageURL, !urlString.isEmpty, let url = URL(string: urlString) {
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
    }

    // Función para cerrar sesión y navegar a la pantalla de LoginView
    func logout() {
        session.signOut()
        self.isLoggedOut = true // Actualizar estado de logout para redirigir a LoginView
    }
}

// Componente para los elementos del menú
struct MenuItem: View {
    var icon: String // Nombre del icono del sistema
    var text: String // Texto de la opción del menú
    var action: () -> Void // Acción a ejecutar cuando se selecciona el elemento

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon) // Icono del elemento del menú
                    .foregroundColor(.primary) // Cambiar a .primary para adaptarse al modo oscuro
                Text(text) // Texto del elemento del menú
                    .font(.headline)
                    .foregroundColor(.primary) // Cambiar a .primary para adaptarse al modo oscuro
                Spacer() // Espacio flexible para empujar el texto a la izquierda
            }
            .padding()
        }
    }
}

// Vista de previsualización para SwiftUI
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(isOpen: .constant(true))
            .environmentObject(SessionStore()) // Añadir SessionStore para la previsualización
    }
}

