import Foundation
import SwiftData

/// `FavoriteRepository` con SwiftData.
/// `@ModelActor` le da un `ModelContext` propio, aislado del hilo principal.
/// Las vistas no reciben ese contexto: solo ven `[Recipe]` que devuelve el caso de uso.
@ModelActor
actor SwiftDataFavoriteRepository: FavoriteRepository {
    func favorites() async throws -> [Recipe] {
        let descriptor = FetchDescriptor<SwiftDataRecipe>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(RecipeMapper.toDomain)
    }

    func isFavorite(id: String) async throws -> Bool {
        let recipeID = id
        let descriptor = FetchDescriptor<SwiftDataRecipe>(
            predicate: #Predicate { $0.id == recipeID }
        )
        return try !modelContext.fetch(descriptor).isEmpty
    }

    func add(_ recipe: Recipe) async throws {
        modelContext.insert(SwiftDataRecipe(from: recipe))
        try modelContext.save()
    }

    func remove(id: String) async throws {
        let recipeID = id
        let descriptor = FetchDescriptor<SwiftDataRecipe>(
            predicate: #Predicate { $0.id == recipeID }
        )
        for stored in try modelContext.fetch(descriptor) {
            modelContext.delete(stored)
        }
        try modelContext.save()
    }
}
