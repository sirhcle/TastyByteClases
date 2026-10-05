import Foundation

/// Caso de uso: leer los favoritos, del más reciente al más antiguo.
struct ListFavoritesUseCase: Sendable {
    private let repository: any FavoriteRepository

    /// - Parameter repository: Dónde están guardados. En la app es `SwiftDataFavoriteRepository`.
    init(repository: any FavoriteRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Recipe] {
        try await repository.favorites()
    }
}
