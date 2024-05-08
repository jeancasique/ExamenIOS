import SwiftUI

struct MoviesView: View {
    @State private var searchText = ""
    @State private var movies: [Movie] = []
    @StateObject private var movieService = MovieService()

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
                        ProfileIcon()
                    }
                }
            }
            .onAppear {
                loadMovies(searchTerm: "Spider-Man") // Carga inicial con un término predeterminado
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
            .shadow(radius: 5)

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
    var body: some View {
        Image(systemName: "person.crop.circle")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }
}


struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}

