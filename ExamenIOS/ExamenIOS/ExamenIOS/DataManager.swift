import CoreData
import FirebaseFirestore

class DataManager {
    static let shared = DataManager()

    // MARK: - Core Data management
    func addFavoriteMovieToCoreData(movie: Movie, context: NSManagedObjectContext) {
        let favorite = FavoriteMovie(context: context)
        favorite.id = movie.imdbID
        favorite.title = movie.title
        favorite.poster = movie.poster
        favorite.year = movie.year

        do {
            try context.save()
            print("Favorite movie saved in Core Data")
        } catch {
            print("Failed to save favorite movie in Core Data: \(error)")
        }
    }

    func removeFavoriteMovieFromCoreData(movieID: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", movieID)
        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            try context.save()
            print("Favorite movie removed from Core Data")
        } catch {
            print("Failed to remove favorite movie: \(error)")
        }
    }

    func isFavorite(movieID: String, context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", movieID)
        do {
            let result = try context.fetch(fetchRequest)
            return !result.isEmpty
        } catch {
            print("Error fetching: \(error)")
            return false
        }
    }

    func fetchFavoriteMoviesFromCoreData(context: NSManagedObjectContext) -> [FavoriteMovie] {
        let request: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch favorite movies from Core Data: \(error)")
            return []
        }
    }

    // MARK: - Firebase Firestore management
    func addFavoriteMovieToFirebase(movie: Movie, userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("favorites").document(movie.imdbID).setData([
            "title": movie.title,
            "poster": movie.poster,
            "year": movie.year,
            "id": movie.imdbID
        ]) { error in
            if let error = error {
                print("Error adding favorite movie to Firebase: \(error)")
            } else {
                print("Favorite movie successfully added to Firebase!")
            }
        }
    }

    func fetchFavoriteMoviesFromFirebase(userId: String, completion: @escaping ([Movie]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("favorites").getDocuments { (snapshot, error) in
            var movies: [Movie] = []
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let movie = Movie(
                        title: data["title"] as? String ?? "",
                        year: data["year"] as? String ?? "",
                        poster: data["poster"] as? String ?? "",
                        imdbID: data["id"] as? String ?? ""
                    )
                    movies.append(movie)
                }
            }
            completion(movies)
        }
    }
}
