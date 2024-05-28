import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FavoritesMovies: View {
    @State private var searchText = "" // Estado para el texto de búsqueda
    @State private var favoriteMovies: [Movie] = [] // Estado para almacenar las películas favoritas
    @ObservedObject private var movieService = MovieService() // Servicio para obtener películas
    @State private var isMenuOpen = false // Estado para controlar el menú
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack(alignment: .leading) { // Envolver el contenido en un ZStack
            NavigationView {
                ScrollView {
                    // Disposición en una cuadrícula de las tarjetas de películas
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160)), GridItem(.adaptive(minimum: 160))], spacing: 10) {
                        ForEach(favoriteMovies, id: \.imdbID) { movie in
                            NavigationLink(destination: MovieDetailView(movieID: movie.imdbID)) {
                                MovieCard(movie: movie)
                                    .frame(width: 160, height: 240) // Ajustar tamaño de las tarjetas
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color.black)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: searchText) { newValue in
                    filterMovies(searchTerm: newValue) // Filtrar películas según el término de búsqueda
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle() // Abrir/cerrar el menú
                            }
                        }) {
                            ProfileIcon(userData: session.userData, subText: "Encuentra tu película favorita") // Icono de perfil del usuario
                        }
                    }
                }
                .onAppear {
                    loadUserData() // Cargar datos del usuario
                    loadFavoriteMovies() // Cargar películas favoritas al aparecer la vista
                }
                .navigationBarBackButtonHidden(true) // Ocultar botón de retroceso
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Asegurar el estilo de navegación para ocultar el botón de retroceso
            
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen.toggle() // Cerrar el menú al tocar fuera de él
                        }
                    }

                MenuView(isOpen: $isMenuOpen)
                    .transition(.move(edge: .leading)) // Animación de transición
            }
        }
    }

    // Función para cargar películas favoritas desde Firestore
    private func loadFavoriteMovies() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Obtener el ID del usuario
        let db = Firestore.firestore()
        db.collection("FavoriteMovie").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error loading favorite movies: \(error)")
                return
            }
            guard let documents = snapshot?.documents else { return }
            let movieIds = documents.compactMap { $0.data()["movieId"] as? String }
            fetchMoviesDetails(movieIds: movieIds) // Obtener detalles de las películas por sus IDs
        }
    }

    // Función para obtener detalles de las películas por sus IDs
    private func fetchMoviesDetails(movieIds: [String]) {
        let dispatchGroup = DispatchGroup()
        var fetchedMovies: [Movie] = []
        
        for movieId in movieIds {
            dispatchGroup.enter()
            movieService.fetchMovieDetails(imdbID: movieId) { movie in
                if let movie = movie {
                    fetchedMovies.append(movie)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.favoriteMovies = fetchedMovies // Actualizar estado una vez
        }
    }

    // Función para filtrar películas favoritas basadas en un término de búsqueda
    private func filterMovies(searchTerm: String) {
        if searchTerm.isEmpty {
            loadFavoriteMovies() // Recargar todas las películas favoritas si el término de búsqueda está vacío
        } else {
            favoriteMovies = favoriteMovies.filter { $0.title.lowercased().contains(searchTerm.lowercased()) }
        }
    }

    // Función para cargar datos del usuario desde Firestore
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Obtener el ID del usuario
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.session.userData.firstName = data?["firstName"] as? String ?? "" // Actualizar nombre del usuario
                    if let urlString = data?["profileImageURL"] as? String {
                        self.loadProfileImage(from: urlString) // Cargar imagen de perfil
                    }
                }
            }
        }
    }

    // Función para cargar la imagen de perfil desde una URL
    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.session.userData.profileImage = UIImage(data: data) // Actualizar la imagen de perfil
            }
        }.resume()
    }
}

// Vista de previsualización para SwiftUI
struct FavoritesMovies_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesMovies()
            .environmentObject(SessionStore()) // Proporcionar una instancia de SessionStore para la previsualización
    }
}

