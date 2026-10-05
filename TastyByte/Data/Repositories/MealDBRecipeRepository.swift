import Foundation

/// Implementación de `RecipeRepository` contra TheMealDB.
/// No arma la URL: eso está en `MealDBClient`. Aquí el DTO se convierte en `Recipe`.
struct MealDBRecipeRepository: RecipeRepository {
    func search(query: String) async throws -> [Recipe] {
        let dtos = try await MealDBClient.searchRecipes(query: query)
        return dtos.map(RecipeMapper.toDomain)
    }
}
