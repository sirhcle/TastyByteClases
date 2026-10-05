import Foundation

/// Puerto de las preferencias locales del usuario.
/// La implementación es `UserDefaultsPreferencesRepository`.
protocol PreferencesRepository: Sendable {
    /// Lee la apariencia guardada.
    func loadAppearance() -> AppearancePreference

    /// Sustituye la apariencia guardada.
    func saveAppearance(_ preference: AppearancePreference)
}
