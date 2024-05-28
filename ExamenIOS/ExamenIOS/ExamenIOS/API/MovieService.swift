import Foundation
import Combine

// Clase para interactuar con el API de OMDB y obtener datos de películas
class MovieService: ObservableObject {
    // Tu clave de API para OMDB
    private let apiKey = "fde4bf0f"
    // URL base del API de OMDB
    private let baseURL = URL(string: "https://www.omdbapi.com/")!
    
    // Películas observadas
    @Published var movies: [Movie] = []
    
    // Método para buscar películas
    func fetchMovies(searchTerm: String, completion: @escaping ([Movie]?) -> Void) {
        // Crear los parámetros de la URL con el término de búsqueda y la clave de API
        let queryItems = [
            URLQueryItem(name: "s", value: searchTerm),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        // Construir los componentes de la URL usando la URL base y los parámetros
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        // Verificar que la URL sea válida
        guard let url = urlComponents.url else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        // Crear una tarea de URLSession para obtener datos de la URL
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            // Verificar que se hayan recibido datos y que no haya errores
            guard let data = data, error == nil else {
                print("Error al cargar movies: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                // Decodificar los datos recibidos en una respuesta de película
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                // Llamar al completion handler con los resultados de la búsqueda
                DispatchQueue.main.async {
                    completion(movieResponse.Search)
                }
            } catch {
                // Manejar errores de decodificación
                print("Error decoding movie data: \(error)")
                completion(nil)
            }
        }
        
        // Iniciar la tarea de URLSession
        task.resume()
    }
    
    // Método para obtener detalles de una película específica
    func fetchMovieDetails(imdbID: String, completion: @escaping (Movie?) -> Void) {
        // Crear los parámetros de la URL con el ID de IMDB de la película y la clave de API
        let queryItems = [
            URLQueryItem(name: "i", value: imdbID),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        // Construir los componentes de la URL usando la URL base y los parámetros
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        // Verificar que la URL sea válida
        guard let url = urlComponents.url else {
            print("Invalid URL for movie details")
            completion(nil)
            return
        }
        
        // Crear una tarea de URLSession para obtener datos de la URL
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            // Verificar que se hayan recibido datos y que no haya errores
            guard let data = data, error == nil else {
                print("Error cargando movie details: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                // Decodificar los datos recibidos en una estructura de película
                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(Movie.self, from: data)
                // Llamar al completion handler con los detalles de la película
                DispatchQueue.main.async {
                    completion(movieDetails)
                }
            } catch {
                // Manejar errores de decodificación
                print("Error decoding movie details: \(error)")
                completion(nil)
            }
        }
        
        // Iniciar la tarea de URLSession
        task.resume()
    }

    // Estructura para decodificar la respuesta de búsqueda de películas
    struct MovieResponse: Decodable {
        let Search: [Movie]?
    }
}

