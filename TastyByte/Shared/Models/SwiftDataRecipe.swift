import Foundation
import SwiftData

// MARK: - SwiftDataRecipe
/// Modelo persistente con SwiftData para almacenar las recetas favoritas en SwiftUI.
/// La macro @Model le indica al compilador que transforme esta clase en un esquema de SwiftData.

@Model
final class SwiftDataRecipe{
    
    // MARK: - Propiedades Persistidas
    @Attribute(.unique) var id: String
    var title: String
    var category: String
    var area: String
    var imageUrlString: String
    var instructions: String
    var createdAt: Date
    
    // MARK: - Initializer
    init(id: String, title: String, category: String, area: String, imageUrlString: String, instructions: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.category = category
        self.area = area
        self.imageUrlString = imageUrlString
        self.instructions = instructions
        self.createdAt = createdAt
    }
    
    // MARK: - Convenience Initializer desde Modelo API
    /// Permite instanciar un SwiftDataRecipe directamente desde un modelo `Recipe` devuelto por la red.
    convenience init(from recipe: Recipe) {
        self.init(
            id: recipe.id,
            title: recipe.title,
            category: recipe.category,
            area: recipe.area,
            imageUrlString: recipe.imageUrl?.absoluteString ?? "",
            instructions: recipe.instructions
        )
    }
    
    // MARK: - Helper URL
    var imageUrl: URL? {
        return URL(string: imageUrlString)
    }
}
