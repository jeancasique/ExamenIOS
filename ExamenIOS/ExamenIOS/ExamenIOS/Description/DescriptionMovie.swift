import SwiftUI
import Kingfisher

struct DescriptionMovie: View {
    var movie: Movie
    @State private var isFavorite: Bool = false
    @EnvironmentObject var session: SessionStore

    init(movie: Movie) {
        self.movie = movie
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .bottom) {
                    // Espacio reservado para la imagen
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 400)
                    
                    KFImage(URL(string: movie.poster))
                        .placeholder {
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 600)
                        .clipped()
                        .edgesIgnoringSafeArea(.top)

                    LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .center, endPoint: .bottom)
                        .frame(height: 600)
                }
                .background(Color.black.opacity(0.1))

                HStack {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)

                    Spacer()

                    Button(action: {
                        toggleFavorite()
                    }) {
                        Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 25)
                            .foregroundColor(.red)
                            .padding()
                            .padding(.trailing, 1)
                    }
                }
                .padding(.top, -40)

                Group {
                    if let rating = Double(movie.imdbRating ?? "0") {
                        StarRatingView(rating: rating)
                    }
                    Text("Year: ").bold() + Text(movie.year)
                    Text("Runtime: ").bold() + Text(movie.runtime ?? "N/A")
                    Text("Director: ").bold() + Text(movie.director ?? "Unknown")
                    Text("Genre: ").bold() + Text(movie.genre ?? "Unknown")
                    Text("Country: ").bold() + Text(movie.country ?? "Unknown")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)

                Text(movie.plot ?? "No synopsis available.")
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
            }
        }
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            loadFavoriteStatus()
        }
    }

    private func loadFavoriteStatus() {
        DataManager.shared.isFavorite(movieId: movie.imdbID) { isFavorite in
            DispatchQueue.main.async {
                self.isFavorite = isFavorite
            }
        }
    }

    private func toggleFavorite() {
        if isFavorite {
            DataManager.shared.removeFavorite(movieId: movie.imdbID)
        } else {
            DataManager.shared.addFavorite(movieId: movie.imdbID, movieTitle: movie.title)
            NotificationManager.shared.scheduleLocalNotification(movieTitle: movie.title)
        }
        isFavorite.toggle()
    }
}

// Vista de previsualización para SwiftUI
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
        .preferredColorScheme(.dark)
        .environmentObject(SessionStore())
    }
}

// Vista para mostrar la calificación con estrellas
struct StarRatingView: View {
    var rating: Double

    private func starType(index: Int) -> String {
        let filledStars = Int(rating / 2)
        let hasHalfStar = (rating.truncatingRemainder(dividingBy: 2) >= 0.5)
        if index < filledStars {
            return "star.fill"
        } else if index == filledStars && hasHalfStar {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starType(index: index))
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f/10", rating))
                .fontWeight(.bold)
        }
    }
}

