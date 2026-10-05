import Foundation

/// Entidad de dominio: la receta como la usa la app, ya sin claves del JSON (`strMeal`, `idMeal`).
/// `RecipeDTO` es quien decodifica la API. `RecipeMapper` convierte uno en el otro.
struct Recipe: Equatable, Sendable, Identifiable {
    /// Identificador de TheMealDB (`idMeal`).
    let id: String
    /// Nombre del platillo.
    let title: String
    /// Categoría (por ejemplo "Chicken"). Si el JSON no trae una, el mapper pone "General".
    let category: String
    /// Origen de la cocina (por ejemplo "Mexican"). Si falta, el mapper pone "Internacional".
    let area: String
    /// Pasos de preparación. Si faltan, el mapper pone un texto de respaldo.
    let instructions: String
    /// Miniatura en texto, no como `URL`. La vista decide cómo descargarla (Kingfisher, por ejemplo).
    let imageURL: String?
}
