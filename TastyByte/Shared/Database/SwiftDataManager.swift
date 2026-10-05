import Foundation
import SwiftData

/// Abre el `ModelContainer` de los favoritos.
/// Ya no es un singleton: `AppFactory` lo crea al arrancar. Si falla, el error sube y la app muestra `StartupErrorViewController`.
final class SwiftDataManager {
    let container: ModelContainer

    init() throws {
        container = try ModelContainer(for: SwiftDataRecipe.self)
    }
}
