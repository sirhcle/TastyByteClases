import Foundation

// MARK: - NetworkError
/// Enumerador de errores personalizados para identificar fallas en la capa de red.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida"
        case .decodingError:
            return "Error al decodificar la respuesta"
        case .serverError(let message):
            return "Error del servidor: \(message)"
        }
    }
}

// MARK: - NetworkManager
/// Clase Singleton encargada de realizar todas las peticiones HTTP a la API de TheMealDB.
final class NetworkManager {
    
    /// Instancia única compartida (Patrón Singleton)
    static let shared = NetworkManager()
    
    /// URL base pública de la API gratuita de TheMealDB (Usa la clave de pruebas '1')
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    /// Constructor privado para evitar instanciación externa
    private init() {}
    
    // MARK: - Métodos Públicos
    
    /// Busca recetas por término o devuelve un catálogo base.
    /// - Parameter query: Texto ingresado por el usuario (ej. "Chicken" o "Pasta").
    /// - Returns: Arreglo de recetas ([Recipe]).
    func searchRecipes(query: String) async throws -> [Recipe] {
        
        // Formatear el texto de búsqueda para evitar errores por espacios
        let queryFormatted = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        
        // Si el query está vacío, buscamos recetas con "a" por defecto para llenar la pantalla inicial
        let searchTerm = queryFormatted.isEmpty ? "a" : queryFormatted
        let urlString = "\(baseURL)/search.php?s=\(searchTerm)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Consumo asíncrono con la API moderna de URLSession
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validación de código de estado HTTP (200 OK)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // Decodificación del JSON utilizando JSONDecoder
        do {
            let decodedData = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return decodedData.meals ?? []
            
        } catch {
            print("❌ Error de decodificación: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
        
    }
    
    
}
