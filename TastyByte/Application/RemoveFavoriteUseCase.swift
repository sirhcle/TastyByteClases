import Foundation

/// Caso de uso: quitar un favorito por su identificador.
/// Lo usa el deslizamiento para borrar en la lista de favoritos.
struct RemoveFavoriteUseCase: Sendable {
    private let repository: any FavoriteRepository

    init(repository: any FavoriteRepository) {
        self.repository = repository
    }

    func execute(id: String) async throws {
        try await repository.remove(id: id)
    }
}
