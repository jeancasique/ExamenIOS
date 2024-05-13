import Foundation

class DataManager {
    static let shared = DataManager()
    private let favoritesKey = "favorites"

    // UserDefaults management
    func addFavorite(movieId: String) {
        var favorites = fetchFavorites()
        if !favorites.contains(movieId) {
            favorites.append(movieId)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
            print("Favorite movie added")
        }
    }

    func removeFavorite(movieId: String) {
        var favorites = fetchFavorites()
        if let index = favorites.firstIndex(of: movieId) {
            favorites.remove(at: index)
            UserDefaults.standard.set(favorites, forKey: favoritesKey)
            print("Favorite movie removed")
        }
    }

    func isFavorite(movieId: String) -> Bool {
        let favorites = fetchFavorites()
        return favorites.contains(movieId)
    }

    private func fetchFavorites() -> [String] {
        return UserDefaults.standard.array(forKey: favoritesKey) as? [String] ?? []
    }
}

