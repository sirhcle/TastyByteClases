import Foundation

/// Puerto del historial de búsquedas confirmadas.
/// La implementación actual es `SQLiteSearchHistoryRepository`.
protocol SearchHistoryRepository: Sendable {
    /// Últimas búsquedas, de la más reciente a la más antigua.
    /// - Parameter limit: Máximo de filas a devolver.
    func recentSearches(limit: Int) async throws -> [SearchEntry]

    /// Crea el término o, si ya existe, actualiza su fecha.
    /// Quien llama entrega el texto ya recortado y no vacío (`RecordSearchUseCase`).
    func record(query: String) async throws

    /// Borra una fila del historial por su llave de SQLite.
    func delete(id: Int64) async throws
}
