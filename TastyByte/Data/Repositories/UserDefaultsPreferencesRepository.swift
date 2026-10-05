import Foundation

/// `PreferencesRepository` sobre `UserDefaults`.
/// Usa la misma clave que `UserDefaultsManager` (`isDarkModeEnabled`) para no perder el modo oscuro ya guardado.
struct UserDefaultsPreferencesRepository: PreferencesRepository {
    private let defaults: UserDefaults
    private let darkModeKey = "isDarkModeEnabled"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadAppearance() -> AppearancePreference {
        AppearancePreference(isDarkModeEnabled: defaults.bool(forKey: darkModeKey))
    }

    func saveAppearance(_ preference: AppearancePreference) {
        defaults.set(preference.isDarkModeEnabled, forKey: darkModeKey)
    }
}
