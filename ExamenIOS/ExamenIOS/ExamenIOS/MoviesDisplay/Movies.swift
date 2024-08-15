import Foundation
import SwiftUI

struct Movie: Decodable, Identifiable, Equatable {
    let id = UUID() // Necesario para Identifiable
    let title: String
    let year: String
    let rated: String?
    let released: String?
    let runtime: String?
    let genre: String?
    let director: String?
    let writer: String?
    let actors: String?
    let plot: String?
    let language: String?
    let country: String?
    let awards: String?
    let poster: String
    let ratings: [Rating]?
    let metascore: String?
    let imdbRating: String?
    let imdbVotes: String?
    let imdbID: String
    let type: String?
    let dvd: String?
    let boxOffice: String?
    let production: String?
    let website: String?

    struct Rating: Decodable {
        let source: String?
        let value: String?
    }

    private enum CodingKeys: String, CodingKey {
        case title = "Title", year = "Year", rated = "Rated", released = "Released",
             runtime = "Runtime", genre = "Genre", director = "Director", writer = "Writer",
             actors = "Actors", plot = "Plot", language = "Language", country = "Country",
             awards = "Awards", poster = "Poster", ratings = "Ratings", metascore = "Metascore",
             imdbRating, imdbVotes, imdbID = "imdbID", type = "Type", dvd = "DVD",
             boxOffice = "BoxOffice", production = "Production", website = "Website"
    }

    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.imdbID == rhs.imdbID
    }
}

