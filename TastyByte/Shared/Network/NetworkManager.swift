import Foundation

// MARK: - NetworkManager
/// Fachada delgada sobre `MealDBClient`.
/// Las listas de UIKit y SwiftUI ya no la usan: piden recetas con `SearchRecipesUseCase`.
/// Queda para el ejemplo comentado en `MainSelectorViewController`.
final class NetworkManager {

    static let shared = NetworkManager()

    private init() {}

    /// Busca recetas por término o devuelve un catálogo base.
    /// - Parameter query: Texto ingresado por el usuario (ej. "Chicken" o "Pasta").
    /// - Returns: Arreglo de DTOs de receta ([RecipeDTO]).
    func searchRecipes(query: String) async throws -> [RecipeDTO] {
        try await MealDBClient.searchRecipes(query: query)
    }
}
