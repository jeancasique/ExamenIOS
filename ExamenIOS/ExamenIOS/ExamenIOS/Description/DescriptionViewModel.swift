import Foundation

class DescriptionViewModel: ObservableObject {
    @Published var isFavorite: Bool = false
    private var movieId: String
    private let dataManager = DataManager.shared

    init(movieId: String) {
        self.movieId = movieId
        loadFavoriteStatus()
    }

    private func loadFavoriteStatus() {
        dataManager.isFavorite(movieId: movieId) { [weak self] isFavorite in
            DispatchQueue.main.async {
                self?.isFavorite = isFavorite
            }
        }
    }

    func toggleFavorite(movieTitle: String) {
        if isFavorite {
            dataManager.removeFavorite(movieId: movieId)
        } else {
            dataManager.addFavorite(movieId: movieId, movieTitle: movieTitle)
            NotificationManager.shared.scheduleLocalNotification(movieTitle: movieTitle)
        }
        isFavorite.toggle()
    }
}

