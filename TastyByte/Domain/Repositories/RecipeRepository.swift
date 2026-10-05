import Foundation

/// Puerto para obtener recetas. El dominio declara el contrato; la implementación concreta vive en Data.
/// Hoy esa implementación es `MealDBRecipeRepository`. Un test puede pasar otro tipo que cumpla este protocolo.
protocol RecipeRepository: Sendable {
    /// Busca recetas por texto.
    /// - Parameter query: Texto del usuario. Vacío significa "trae el catálogo base".
    /// - Returns: Entidades de dominio, ya mapeadas. Nunca DTOs.
    func search(query: String) async throws -> [Recipe]
}
