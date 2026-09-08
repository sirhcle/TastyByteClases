import Foundation
import SQLite

//MARK: - SearchItem Model
struct SearchItem: Identifiable {
    let id: Int64
    let query: String
    let date: Date
}

//MARK: - SQLIteManager

final class SQLiteManager {
    
    //instancia compartida Singleton
    static let shared = SQLiteManager()
    
    //MARK: - Referencia a la base de datos y tabla
    private var db: Connection?
    private let searchTable = Table("search_history")
    
    //MARK: -  Definicion de columnas de la tabla
    private let id = Expression<Int64>("id")
    private let queryText = Expression<String>("query_text")
    private let createdAt = Expression<Date>("created_at")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let documentURL = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let dbPath = documentURL.appendingPathComponent("TastyByteSearch.sqlite3").path
            
            //Establecer conexion con el archivo SQLite
            db = try Connection(dbPath)
            print("✅ Base de datos SQLite creada/conectada en: \(dbPath)")
            
            //Crear la tabla si no existe
            createTableIfNeeded()
        } catch {
            print("❌ Error al inicializar SQLite: \(error.localizedDescription)")
        }
    }
    
    /// Sentencia CREATE TABLE IF NOT EXIST
    private func createTableIfNeeded() {
        guard let db = db else { return }
        
        do {
            try db.run(searchTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(queryText)
                table.column(createdAt)
            })
            print("✅ Tabla 'search_history' verificada/creada correctamente.")
            
        } catch {
            print("❌ Error al crear la tabla en SQLite: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Operaciones CRUD (Create, Read, Delete)
    
    /// Guarda un nuevo término de búsqueda en la base de datos (CREATE).
    /// - Parameter query: Texto que buscó el usuario.
    func saveSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let db = db else { return }
        
        do {
            let insert = searchTable.insert(
                queryText <- trimmed,
                createdAt <- Date()
            )
            try db.run(insert)
            print("✅ Búsqueda '\(trimmed)' guardada en SQLite.")
        } catch {
            print("❌ Error al guardar en SQLite: \(error.localizedDescription)")
        }
    }
    
    /// Consulta el historial completo de búsquedas ordenado por fecha más reciente (READ).
    /// - Returns: Arreglo de `SearchItem`.
    func fetchSearchHistory() -> [SearchItem] {
        guard let db = db else { return [] }
        var history: [SearchItem] = []
        
        do {
            // Consulta SELECT * FROM search_history ORDER BY created_at DESC LIMIT 10
            let query = searchTable.order(createdAt.desc).limit(10)
            
            for item in try db.prepare(query) {
                let searchItem = SearchItem(
                    id: item[id],
                    query: item[queryText],
                    date: item[createdAt]
                )
                history.append(searchItem)
            }
        } catch {
            print("❌ Error al leer historial de SQLite: \(error.localizedDescription)")
        }
        return history
    }
    
    /// Elimina un elemento del historial por su ID (DELETE).
    /// - Parameter searchId: ID primario del registro.
    func deleteSearch(id searchId: Int64) {
        guard let db = db else { return }
        
        do {
            let itemToDelete = searchTable.filter(id == searchId)
            try db.run(itemToDelete.delete())
            print("✅ Registro de historial eliminado de SQLite.")
        } catch {
            print("❌ Error al eliminar en SQLite: \(error.localizedDescription)")
        }
    }
    
    /// Busca un registro existente cuyo texto coincida exactamente con `query`,
    /// sin distinguir mayúsculas/minúsculas ("Pollo" y "pollo" se consideran el mismo).
    /// - Returns: el `SearchItem` encontrado, o `nil` si no existe todavía.
    func findSearch(query: String) -> SearchItem? {
        guard let db = db else { return nil }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            let match = searchTable.filter(queryText.collate(.nocase) == trimmed)
            if let row = try db.pluck(match) {
                return SearchItem(id: row[id], query: row[queryText], date: row[createdAt])
            }
        } catch {
            print("❌ Error al buscar en SQLite: \(error.localizedDescription)")
        }
        
        return nil
    }

    /// Actualiza la fecha de un registro existente a "ahora" (UPDATE).
    /// No cambia el texto de la búsqueda — solo refleja que se volvió a buscar lo mismo.
    /// - Parameter searchId: ID primario del registro a actualizar.
    func updateSearch(id searchId: Int64) {
        guard let db = db else { return }
        
        do {
            let itemToUpdate = searchTable.filter(id == searchId)
            try db.run(itemToUpdate.update(createdAt <- Date()))
            print("✅ Registro de historial actualizado (nueva fecha) en SQLite.")
        } catch {
            print("❌ Error al actualizar en SQLite: \(error.localizedDescription)")
        }
    }

    /// Punto de entrada recomendado al confirmar una búsqueda: si el término ya existe
    /// en el historial, actualiza su fecha (UPDATE); si no existe, lo crea (INSERT).
    /// Este patrón se conoce como "upsert" (update + insert).
    func saveOrUpdateSearch(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let existing = findSearch(query: trimmed)
        {
            //TODO: actualizar
            updateSearch(id: existing.id)
        } else {
            //TODO: salvar registro nuevo
            saveSearch(query: trimmed)
        }
    }
}


