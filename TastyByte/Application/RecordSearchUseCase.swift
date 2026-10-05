import Foundation

/// Caso de uso: guardar una búsqueda confirmada.
/// No se invoca en cada tecla. Enter y las sugerencias son los únicos disparadores.
struct RecordSearchUseCase: Sendable {
    private let repository: any SearchHistoryRepository

    /// - Parameter repository: Dónde persistir el historial. En la app es `SQLiteSearchHistoryRepository`.
    init(repository: any SearchHistoryRepository) {
        self.repository = repository
    }

    /// Recorta el texto. Si queda vacío, no escribe nada.
    /// - Parameter query: Texto del buscador, pueda o no traer espacios.
    func execute(query: String) async throws {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try await repository.record(query: trimmed)
    }
}
