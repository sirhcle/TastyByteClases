import Combine
import Foundation

/// Estado de la lista de recetas, compartido por SwiftUI y UIKit.
/// La vista solo llama a estos métodos. Los casos de uso, inyectados en el `init`, hablan con los repositorios.
/// Crear este objeto no busca en internet: la petición empieza en `loadIfNeeded()` o `submitSearch()`.
@MainActor
final class RecipeListViewModel: ObservableObject {
    /// Recetas que hay que pintar. La vista observa este arreglo.
    @Published private(set) var recipes: [Recipe] = []
    /// `true` mientras hay una petición en curso.
    @Published private(set) var isLoading = false
    /// Texto del buscador. La vista lo escribe; `submitSearch()` lo lee al confirmar.
    @Published var searchText = ""
    /// Mensaje para la alerta. `nil` cuando no hay error.
    @Published private(set) var errorMessage: String?
    /// Sugerencias del buscador. Las pantallas las pintan; no leen SQLite.
    @Published private(set) var suggestions: [SearchEntry] = []

    private let searchRecipes: SearchRecipesUseCase
    private let recordSearch: RecordSearchUseCase
    private let suggestSearches: SuggestSearchesUseCase
    /// Se cancela si el usuario sigue tecleando: solo importa el texto más reciente.
    private var suggestionsTask: Task<Void, Never>?

    /// Inyección por inicializador. `AppFactory` elige TheMealDB y SQLite.
    init(
        searchRecipes: SearchRecipesUseCase,
        recordSearch: RecordSearchUseCase,
        suggestSearches: SuggestSearchesUseCase
    ) {
        self.searchRecipes = searchRecipes
        self.recordSearch = recordSearch
        self.suggestSearches = suggestSearches
    }

    /// Catálogo inicial, al aparecer la pantalla.
    /// No guarda historial: el usuario todavía no confirmó un texto.
    /// Si ya hay recetas o una carga en curso, no dispara otra petición.
    func loadIfNeeded() {
        guard recipes.isEmpty, !isLoading else { return }
        isLoading = true
        Task {
            await fetch(query: "")
        }
    }

    /// Enter o una sugerencia. Primero guarda el término y después pide recetas.
    /// Si SQLite falla, la búsqueda en internet sigue: el historial no bloquea el catálogo.
    func submitSearch() {
        let texto = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return }

        isLoading = true
        Task {
            do {
                try await recordSearch.execute(query: texto)
            } catch {
                print("❌ No se pudo guardar la búsqueda: \(error.localizedDescription)")
            }
            refreshSuggestions(matching: texto)
            await fetch(query: texto)
        }
    }

    /// Cada tecla. No guarda el término: solo filtra el historial ya confirmado.
    func refreshSuggestions(matching text: String) {
        suggestionsTask?.cancel()
        suggestionsTask = Task {
            do {
                let entries = try await suggestSearches.execute(matching: text)
                if Task.isCancelled { return }
                suggestions = entries
            } catch {
                if Task.isCancelled { return }
                suggestions = []
            }
        }
    }

    /// Cierra la alerta. La vista lo llama al tocar OK.
    func dismissError() {
        errorMessage = nil
    }

    /// Punto único que habla con `SearchRecipesUseCase` y publica el resultado.
    private func fetch(query: String) async {
        do {
            recipes = try await searchRecipes.execute(query: query)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
