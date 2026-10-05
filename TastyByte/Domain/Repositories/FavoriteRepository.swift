import Foundation

/// Puerto para las recetas marcadas como favoritas.
/// La implementación es `SwiftDataFavoriteRepository`. Las pantallas no tocan `ModelContext`.
protocol FavoriteRepository: Sendable {
    /// Favoritos del más reciente al más antiguo.
    func favorites() async throws -> [Recipe]

    /// `true` si esa receta ya está guardada.
    func isFavorite(id: String) async throws -> Bool

    /// Guarda la receta como favorita.
    func add(_ recipe: Recipe) async throws

    /// Quita el favorito con ese identificador.
    func remove(id: String) async throws
}
