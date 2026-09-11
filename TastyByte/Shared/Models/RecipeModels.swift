import Foundation
// MARK: - RecipeResponse
/// Estructura raíz devuelta por la API de TheMealDB.
/// La API siempre retorna un objeto con la clave "meals" que contiene un arreglo de recetas.

struct RecipeResponse: Codable {
    let meals: [Recipe]?
}

// MARK: - Recipe
/// Modelo principal que representa una receta de cocina.
/// Conforma `Codable` para mapear el JSON y `Identifiable` para usarlo fácilmente en Listas de SwiftUI.
struct Recipe: Codable, Identifiable{
    // MARK: - Propiedades mapeadas directamente del JSON
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    
    // MARK: - Identificador requerido por el protocolo Identifiable
    var id: String {
        return idMeal
    }
    
    // MARK: - Propiedades computadas (Helpers para la Interfaz Gráfica)
    // Facilitan el acceso a los datos limpios en UIKit y SwiftUI sin desempaquetar optionals en la Vista.
    
    /// Nombre del platillo
    var title: String {
        return strMeal
    }
    
    /// Categoría del platillo (ej. "Chicken", "Seafood")
    var category: String {
        return strCategory ?? "General"
    }
    
    /// Origen o tipo de cocina (ej. "Italian", "Mexican")
    var area: String {
        return strArea ?? "Internacional"
    }
    
    /// Instrucciones paso a paso de preparación
    var instructions: String {
        return strInstructions ?? "Sin instrucciones disponibles para esta receta."
    }
    
    /// URL formateada para cargar la imagen con Kingfisher o AsyncImage
    var imageUrl: URL? {
        guard let strMealThumb = strMealThumb else { return nil }
        return URL(string: strMealThumb)
    }
    
}
