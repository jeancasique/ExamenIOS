import Foundation
import FirebaseFirestore
import Combine

// Modelo para el documento de película favorita en Firestore
struct FavoriteMovieDocument: Decodable {
    let userId: String
    let movieId: String
}

// Servicio para obtener las películas favoritas y sus detalles
class FavoritesService {
    private let db = Firestore.firestore()
    private let movieService = MovieService()

    func fetchFavoriteMovies(for userId: String, completion: @escaping ([Movie]?) -> Void) {
        db.collection("FavoriteMovie").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                print("Error loading favorite movies: \(error)")
                completion(nil)
                return
            }
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }
            let movieIds = documents.compactMap { $0.data()["movieId"] as? String }
            self.fetchMoviesDetails(movieIds: movieIds, completion: completion)
        }
    }

    private func fetchMoviesDetails(movieIds: [String], completion: @escaping ([Movie]?) -> Void) {
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
            completion(fetchedMovies)
        }
    }
}
