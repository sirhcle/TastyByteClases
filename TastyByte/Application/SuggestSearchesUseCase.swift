import Foundation

/// Caso de uso: sugerencias del buscador mientras se escribe.
/// Lee el historial y se queda con las que contienen el texto. No guarda nada.
struct SuggestSearchesUseCase: Sendable {
    private let repository: any SearchHistoryRepository

    init(repository: any SearchHistoryRepository) {
        self.repository = repository
    }

    /// - Parameter matching: Texto actual del campo. Vacío devuelve las más recientes.
    /// - Returns: Como máximo 5 entradas.
    func execute(matching text: String) async throws -> [SearchEntry] {
        let history = try await repository.recentSearches(limit: 10)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.isEmpty
            ? history
            : history.filter { $0.query.localizedCaseInsensitiveContains(trimmed) }
        return Array(filtered.prefix(5))
    }
}
