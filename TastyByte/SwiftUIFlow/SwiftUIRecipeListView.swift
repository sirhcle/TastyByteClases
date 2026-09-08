import SwiftUI

struct SwiftUIRecipeListView: View {
    
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    
    
    var body: some View {
        NavigationStack {
            Group {
                //TODO: Listado de recetas
                Color.clear
            }
        }
        .navigationTitle("Recetas (SwiftUI)")
        .searchable(text: $searchText, prompt: "Buscar receta")
        .searchSuggestions {
            //TODO: Filtrados de búsqueda
            ForEach(filteredSuggestions) { item in
                Text(item.query)
                    .searchCompletion(item.query)
                    .onAppear {
                        print("🔍 Item: \(item.query) Fecha: \(item.date.formatted(date: .abbreviated, time: .shortened))")
                    }
            }
        }
        .onSubmit(of: .search) {
            performSearch()
        }
    }
    
    /// Historial filtrado según lo que el usuario va escribiendo en `searchText`.
    /// Al ser una propiedad computada leída dentro de `body`, SwiftUI la recalcula
    /// automáticamente en cada tecla (cada cambio de `searchText` re-evalúa `body`).
    /// NO guarda nada en SQLite — solo lee y filtra lo que ya existe.
    private var filteredSuggestions: [SearchItem] {
        let historial = SQLiteManager.shared.fetchSearchHistory()
        guard !searchText.isEmpty else { return Array(historial.prefix(5)) }
        
        return Array(historial
            .filter{$0.query.localizedCaseInsensitiveContains(searchText)}
            .prefix(5)
        )
    }
    
    
    // MARK: - Acciones
    
    /// Se ejecuta SOLO cuando el usuario confirma una búsqueda —al presionar Enter,
    /// o al tocar una sugerencia (.searchCompletion dispara .onSubmit automáticamente)—
    /// nunca en cada tecleo. Por eso el guardado en SQLite vive aquí.
    private func performSearch() {
        let texto = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !texto.isEmpty else { return }
        
        //SQLiteManager.shared.saveSearch(query: texto)
        SQLiteManager.shared.saveOrUpdateSearch(query: texto)
    }
    
    
}

