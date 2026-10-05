import Foundation

/// Traduce modelos de datos a la entidad `Recipe`.
/// Desde la red usa `RecipeDTO` (con los textos de respaldo "General" e "Internacional").
/// Desde disco usa `SwiftDataRecipe`.
enum RecipeMapper {
    /// - Parameter dto: Un elemento del arreglo `meals` ya decodificado.
    /// - Returns: La entidad que ven los casos de uso y las pantallas.
    static func toDomain(_ dto: RecipeDTO) -> Recipe {
        Recipe(
            id: dto.id,
            title: dto.title,
            category: dto.category,
            area: dto.area,
            instructions: dto.instructions,
            imageURL: dto.imageUrl?.absoluteString
        )
    }

    /// - Parameter stored: Fila de SwiftData. Una miniatura vacía vuelve a `nil`.
    static func toDomain(_ stored: SwiftDataRecipe) -> Recipe {
        Recipe(
            id: stored.id,
            title: stored.title,
            category: stored.category,
            area: stored.area,
            instructions: stored.instructions,
            imageURL: stored.imageUrlString.isEmpty ? nil : stored.imageUrlString
        )
    }
}
