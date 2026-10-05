import Combine
import Foundation

/// Estado de los favoritos, compartido por el catálogo y la pestaña de favoritos.
/// Crear el objeto no lee SwiftData: la lectura empieza en `load()`.
@MainActor
final class FavoritesViewModel: ObservableObject {
    /// Favoritos actuales, del más reciente al más antiguo.
    @Published private(set) var favorites: [Recipe] = []
    /// Mensaje para la alerta. `nil` cuando no hay error.
    @Published private(set) var errorMessage: String?

    private let listFavorites: ListFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let removeFavorite: RemoveFavoriteUseCase

    /// Los tres casos de uso comparten el mismo repositorio, inyectado desde `MainSelectorViewController`.
    init(
        listFavorites: ListFavoritesUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        removeFavorite: RemoveFavoriteUseCase
    ) {
        self.listFavorites = listFavorites
        self.toggleFavorite = toggleFavorite
        self.removeFavorite = removeFavorite
    }

    /// Lee el disco y publica la lista. Se llama al abrir el flujo.
    func load() {
        Task {
            await reload()
        }
    }

    /// Corazón del catálogo. Después de guardar o quitar, vuelve a leer la lista.
    func toggle(_ recipe: Recipe) {
        Task {
            do {
                try await toggleFavorite.execute(recipe)
                await reload()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Borrado de la lista de favoritos. `offsets` son las filas que el usuario deslizó.
    func remove(at offsets: IndexSet) {
        let ids = offsets.compactMap { index -> String? in
            guard favorites.indices.contains(index) else { return nil }
            return favorites[index].id
        }
        remove(ids: ids)
    }

    /// Borrado de una fila concreta. UIKit lo usa para no depender del índice publicado.
    func remove(id: String) {
        remove(ids: [id])
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains { $0.id == id }
    }

    func dismissError() {
        errorMessage = nil
    }

    private func remove(ids: [String]) {
        Task {
            do {
                for id in ids {
                    try await removeFavorite.execute(id: id)
                }
                await reload()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func reload() async {
        do {
            favorites = try await listFavorites.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
