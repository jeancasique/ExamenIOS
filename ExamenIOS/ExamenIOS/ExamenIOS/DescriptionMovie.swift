import SwiftUI
import CoreData

struct DescriptionMovie: View {
    var movie: Movie
    @State private var isFavorite: Bool = false // Estado inicial no favorito
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: movie.poster)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        case .failure:
                            Image("spider") // Imagen predeterminada en caso de error
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        case .empty:
                            Image("spider") // Imagen predeterminada mientras carga la imagen
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        @unknown default:
                            ProgressView()
                        }
                    }
                    .edgesIgnoringSafeArea(.top)

                    // Gradiente que se difumina hacia el final de la imagen
                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
                }
                .background(Color.black.opacity(0.1))

                // HStack para el título y el botón de favoritos
                HStack {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16) // Padding izquierdo de 16dp

                    Spacer() // Empuja el botón hacia la derecha

                    Button(action: {
                        isFavorite.toggle() // Cambia el estado de favorito
                        print("Is favorite now: \(isFavorite)") // Debugging
                    }) {
                        Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.red)
                            .padding()
                            .padding(.trailing, 16) // Padding derecho de 16dp
                    }
                }
                .padding(.top, -40) // Mover el HStack hacia arriba para que esté justo en el borde de la imagen y el gradiente
                .onAppear {
                                   checkIfFavorite()

                // Información adicional de la película
                Group {
                    Text("Year: ").bold() + Text(movie.year)
                                       Text("Runtime: ").bold() + Text(movie.runtime ?? "N/A")
                                       Text("Director: ").bold() + Text(movie.director ?? "Unknown")
                                       Text("Genre: ").bold() + Text(movie.genre ?? "Unknown")
                                       Text("Country: ").bold() + Text(movie.country ?? "Unknown")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16) // Padding izquierdo de 16dp

                Text(movie.plot ?? "No synopsis available.")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16) // Padding izquierdo de 16dp
            }
        }
        .background(Color.black) // Fondo negro
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
    }
}
    private func checkIfFavorite() {
            isFavorite = DataManager.shared.isFavorite(movieID: movie.imdbID, context: managedObjectContext)
        }

        private func toggleFavorite() {
            isFavorite.toggle()
            if isFavorite {
                DataManager.shared.addFavoriteMovieToCoreData(movie: movie, context: managedObjectContext)
            } else {
                DataManager.shared.removeFavoriteMovieFromCoreData(movieID: movie.imdbID, context: managedObjectContext)
            }
        }
    }

struct DescriptionMovie_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionMovie(movie: Movie(
            title: "Spider-Man 2",
            year: "2004",
            rated: "PG-13",
            released: "June 30, 2004",
            runtime: "127 min",
            genre: "Action, Adventure, Sci-Fi",
            director: "Sam Raimi",
            writer: "Alvin Sargent",
            actors: "Tobey Maguire, Kirsten Dunst, Alfred Molina",
            plot: "Peter Parker is dissatisfied with life when he loses his job, the love of his life and his powers. Amid all the chaos, he must fight Doctor Octavius, who threatens to destroy New York City.",
            language: "English",
            country: "USA",
            awards: "Nominated for 1 Oscar. Another 22 wins & 63 nominations.",
            poster: "https://example.com/spiderman2.jpg",
            ratings: [Movie.Rating(source: "IMDb", value: "7.3/10")],
            metascore: "83",
            imdbRating: "7.3",
            imdbVotes: "531,456",
            imdbID: "tt0316654",
            type: "movie",
            dvd: "November 30, 2004",
            boxOffice: "$373,585,825",
            production: "Sony Pictures",
            website: "N/A"
        ))
        .preferredColorScheme(.dark) // Muestra el preview en modo oscuro si deseas
    }
}

