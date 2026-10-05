import Foundation

/// Caso de uso: pedir recetas.
/// No conoce TheMealDB ni `URLSession`. Solo habla con el `RecipeRepository` que le inyectan.
struct SearchRecipesUseCase: Sendable {
    private let repository: any RecipeRepository

    /// - Parameter repository: Origen de las recetas. En la app es `MealDBRecipeRepository`.
    init(repository: any RecipeRepository) {
        self.repository = repository
    }

    /// - Parameter query: Texto a buscar. Vacío pide el catálogo base; el repositorio decide cómo.
    /// - Returns: Recetas de dominio listas para pintar.
    func execute(query: String) async throws -> [Recipe] {
        try await repository.search(query: query)
    }
}
