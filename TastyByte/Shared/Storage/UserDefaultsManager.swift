import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private enum Keys {
        static let isDarkModeEnabled = "isDarkModeEnabled"
    }
    
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Propiedades de acceso rápido (Getters & Setters)
    var isDarkModeEnabled: Bool {
        get {
            return defaults.bool(forKey: Keys.isDarkModeEnabled)
        }
        set {
            defaults.set(newValue, forKey: Keys.isDarkModeEnabled)
        }
    }
}
