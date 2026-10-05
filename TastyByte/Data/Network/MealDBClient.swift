import Foundation

// MARK: - NetworkError
/// Fallas de la petición HTTP a TheMealDB. No salen del dominio: el repositorio las propaga con `throws`.
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

// MARK: - MealDBClient
/// Cliente HTTP de TheMealDB. Devuelve DTOs; quien implementa `RecipeRepository` los mapea a la entidad.
enum MealDBClient {
    /// URL base pública de la API gratuita de TheMealDB (clave de pruebas `1`).
    private static let baseURL = "https://www.themealdb.com/api/json/v1/1"

    /// Busca recetas por término o devuelve un catálogo base.
    /// - Parameter query: Texto ingresado por el usuario (ej. "Chicken" o "Pasta").
    /// - Returns: Arreglo de DTOs. `meals` nulo se traduce a arreglo vacío.
    static func searchRecipes(query: String) async throws -> [RecipeDTO] {
        let queryFormatted = query.trimmingCharacters(in: .whitespacesAndNewlines)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        // Query vacío: la API no lista el catálogo completo. "a" llena la pantalla inicial.
        let searchTerm = queryFormatted.isEmpty ? "a" : queryFormatted
        let urlString = "\(baseURL)/search.php?s=\(searchTerm)"

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        do {
            let decodedData = try JSONDecoder().decode(RecipeResponse.self, from: data)
            return decodedData.meals ?? []
        } catch {
            print("❌ Error de decodificación: \(error.localizedDescription)")
            throw NetworkError.decodingError
        }
    }
}
