import Foundation

/// Un término que el usuario ya confirmó en el buscador (Enter o una sugerencia).
/// No se crea en cada tecla: solo al confirmar.
struct SearchEntry: Equatable, Sendable, Identifiable {
    /// Llave de la fila en SQLite.
    let id: Int64
    /// Texto buscado, ya recortado.
    let query: String
    /// Momento en que se confirmó, o la última vez que se volvió a buscar lo mismo.
    let date: Date
}
