import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MoviesView: View {
    @State private var searchText = ""
    @State private var movies: [Movie] = []
    @StateObject private var movieService = MovieService()
    @StateObject private var userData = UserData()
    
    var body: some View {
        NavigationView {
            ScrollView {
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
                loadMovies(searchTerm: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: PerfilView()) {
                        ProfileIcon(userData: userData)
                    }
                }
            }
            .onAppear {
                loadMovies(searchTerm: "Spider-Man") // Carga inicial con un término predeterminado
                loadUserData() // Cargar datos del usuario
            }
        }
    }

    private func loadMovies(searchTerm: String) {
        movieService.fetchMovies(searchTerm: searchTerm) { result in
            DispatchQueue.main.async {
                movies = result ?? []
            }
        }
    }

    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                DispatchQueue.main.async {
                    self.userData.firstName = data?["firstName"] as? String ?? ""
                    if let urlString = data?["profileImageURL"] as? String {
                        self.loadProfileImage(from: urlString)
                    }
                }
            }
        }
    }

    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.userData.profileImage = UIImage(data: data)
            }
        }.resume()
    }
}

struct MovieDetailView: View {
    let movieID: String
    @State private var movie: Movie?
    @ObservedObject var movieService = MovieService()

    var body: some View {
        Group {
            if let movie = movie {
                DescriptionMovie(movie: movie)
            } else {
                Text("Loading...")
                    .onAppear {
                        movieService.fetchMovieDetails(imdbID: movieID) { fetchedMovie in
                            self.movie = fetchedMovie
                        }
                    }
            }
        }
    }
}

struct MovieCard: View {
    var movie: Movie

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
            
            Text(movie.title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(width: 160, alignment: .leading)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
        .background(Color.black)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 160, height: 240) // Tamaño fijo para toda la tarjeta
    }
}

struct ProfileIcon: View {
    @ObservedObject var userData: UserData
    
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
                Text(userData.firstName.isEmpty ? "Hola, usuario!" : "Hola, \(userData.firstName)!")

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

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}

