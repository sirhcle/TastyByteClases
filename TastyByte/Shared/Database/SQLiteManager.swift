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
    
}

