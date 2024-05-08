import SwiftUI


struct DescriptionMovie: View {
    var movie: Movie

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Imagen de portada
                AsyncImage(url: URL(string: movie.poster)) { phase in
                    if let image = phase.image {
                        image.resizable()
                             .aspectRatio(contentMode: .fit)
                             .cornerRadius(12)
                    } else if phase.error != nil {
                        Text("There was an error loading the image.")
                            .foregroundColor(.red)
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 300)

                // Título de la película
                Text(movie.title)
                    .font(.title2)
                    .fontWeight(.bold)

                // Información de la película
                Group {
                    Text("Year: \(movie.year)")
                    Text("Rating: \(movie.rated ?? "NR")")
                    Text("Runtime: \(movie.runtime ?? "N/A")")
                    Text("Director: \(movie.director ?? "Unknown")")
                    Text("Genre: \(movie.genre ?? "Unknown")")
                    Text("Country: \(movie.country ?? "Unknown")")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 1)

                Text(movie.plot ?? "No synopsis available.")
                    .font(.body)
                    .padding(.bottom, 5)
            }
            .padding()
        }
        .navigationTitle("Movie Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
// Providing a sample movie for preview
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
    }
}

