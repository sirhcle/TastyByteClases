import Foundation

/// Implementación de `SearchHistoryRepository` sobre `SQLiteManager`.
/// Adapta `SearchItem` (fila de SQLite) a `SearchEntry` (entidad de dominio).
struct SQLiteSearchHistoryRepository: SearchHistoryRepository {
    /// Lo inyecta `AppFactory`. Esta clase no pide `SQLiteManager.shared`.
    private let manager: SQLiteManager

    init(manager: SQLiteManager) {
        self.manager = manager
    }

    func recentSearches(limit: Int) async throws -> [SearchEntry] {
        // `fetchSearchHistory` ya limita a 10. `prefix` respeta además el tope que pidió el caso de uso.
        manager.fetchSearchHistory()
            .prefix(max(limit, 0))
            .map { item in
                SearchEntry(id: item.id, query: item.query, date: item.date)
            }
    }

    func record(query: String) async throws {
        // Upsert: si el texto ya existe, solo cambia la fecha.
        manager.saveOrUpdateSearch(query: query)
    }

    func delete(id: Int64) async throws {
        manager.deleteSearch(id: id)
    }
}
