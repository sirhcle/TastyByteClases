import Foundation

/// Caso de uso del corazón: si la receta ya es favorita la quita; si no, la guarda.
/// La vista solo llama a `execute`. No inserta ni borra en SwiftData.
struct ToggleFavoriteUseCase: Sendable {
    private let repository: any FavoriteRepository

    init(repository: any FavoriteRepository) {
        self.repository = repository
    }

    func execute(_ recipe: Recipe) async throws {
        if try await repository.isFavorite(id: recipe.id) {
            try await repository.remove(id: recipe.id)
        } else {
            try await repository.add(recipe)
        }
    }
}
