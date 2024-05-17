import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// Vista principal que muestra una lista de películas
struct MoviesView: View {
    @State private var searchText = "" // Estado para el texto de búsqueda
    @State private var movies: [Movie] = [] // Estado para almacenar las películas
    @StateObject private var movieService = MovieService() // Servicio para obtener películas
    @StateObject private var userData = UserData() // Datos del usuario
    @State private var isMenuOpen = false // Estado para controlar el menú
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack(alignment: .leading) { // Envolver el contenido en un ZStack
            NavigationView {
                ScrollView {
                    // Disposición en una cuadrícula de las tarjetas de películas
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160)), GridItem(.adaptive(minimum: 160))], spacing: 10) {
                        ForEach(movies, id: \.imdbID) { movie in
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
                    loadMovies(searchTerm: newValue) // Cargar películas según el término de búsqueda
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle() // Abrir/cerrar el menú
                            }
                        }) {
                            ProfileIcon(userData: userData) // Icono de perfil del usuario
                        }
                    }
                }
                .onAppear {
                    updateMoviesBasedOnSearchText() // Actualizar películas según el texto del buscador
                    loadUserData() // Cargar datos del usuario
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

    // Función para cargar películas basadas en un término de búsqueda
    private func loadMovies(searchTerm: String) {
        let term = searchTerm.isEmpty ? "Spider-Man" : searchTerm // Usar "Spider-Man" si el término de búsqueda está vacío
        movieService.fetchMovies(searchTerm: term) { result in
            DispatchQueue.main.async {
                movies = result ?? [] // Actualizar el estado con las películas obtenidas
            }
        }
    }

    // Función para actualizar películas según el texto del buscador
    private func updateMoviesBasedOnSearchText() {
        loadMovies(searchTerm: searchText)
    }

    // Función para cargar datos del usuario desde Firestore
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return } // Obtener el ID del usuario
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData.firstName = data?["firstName"] as? String ?? "" // Actualizar nombre del usuario
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
                self.userData.profileImage = UIImage(data: data) // Actualizar la imagen de perfil
            }
        }.resume()
    }
}

// Vista para mostrar los detalles de una película
struct MovieDetailView: View {
    let movieID: String // ID de la película
    @State private var movie: Movie? // Estado para almacenar la película
    @ObservedObject var movieService = MovieService() // Servicio para obtener detalles de películas

    var body: some View {
        Group {
            if let movie = movie {
                DescriptionMovie(movie: movie) // Mostrar detalles de la película
            } else {
                Text("Loading...")
                    .onAppear {
                        movieService.fetchMovieDetails(imdbID: movieID) { fetchedMovie in
                            self.movie = fetchedMovie // Actualizar la película cuando se obtengan los detalles
                        }
                    }
            }
        }
    }
}

// Vista para mostrar una tarjeta de película
struct MovieCard: View {
    var movie: Movie // Película que se mostrará en la tarjeta

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: URL(string: movie.poster)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 200) // Ajustar el tamaño de la imagen
            .clipped()
            .cornerRadius(10)
            .shadow(color: .gray, radius: 9)
            
            VStack {
                Text(movie.title)
                    .font(.title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: 160, alignment: .leading)
                    .foregroundColor(.white)
                
                Text(movie.year ?? "2004")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(width: 160, alignment: .leading)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
        .background(Color.black)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 160, height: 240) // Tamaño fijo para toda la tarjeta
    }
}

// Vista para mostrar el icono de perfil del usuario
struct ProfileIcon: View {
    @ObservedObject var userData: UserData // Datos del usuario
    
    var body: some View {
        HStack(spacing: 8) {
            if let profileImage = userData.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 35, height: 35)
                    .foregroundColor(.gray)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(userData.firstName.isEmpty ? "Hola, usuario!" : "Hola \(userData.firstName)!")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                Text("Encuentra tu película favorita")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .italic(true)
            }
        }
    }
}

// Vista de previsualización para SwiftUI
struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
            .environmentObject(SessionStore()) // Proporcionar una instancia de SessionStore para la previsualización
    }
}

