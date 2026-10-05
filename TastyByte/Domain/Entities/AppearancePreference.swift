import Foundation

/// Preferencia de apariencia que debe sobrevivir entre sesiones.
/// El puerto es `PreferencesRepository`. La pantalla de inicio no abre `UserDefaults`.
struct AppearancePreference: Equatable, Sendable {
    /// `true` fuerza el modo oscuro en las ventanas de la escena.
    var isDarkModeEnabled: Bool
}
