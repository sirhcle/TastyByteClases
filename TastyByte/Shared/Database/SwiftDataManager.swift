import Foundation
import SwiftData

// MARK: - SwiftDataManager
/// Manager singleton que administra el ModelContainer de SwiftData.

final class SwiftDataManager {
    static let shared = SwiftDataManager()
        
    let container: ModelContainer
    
    private init() {
        do {
            container = try ModelContainer(for: SwiftDataRecipe.self)
        } catch {
            fatalError("❌ Error al inicializar SwiftData ModelContainer: \(error)")
        }
    }
}
