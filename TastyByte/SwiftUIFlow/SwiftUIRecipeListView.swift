import SwiftUI
import Kingfisher
import SwiftData

struct SwiftUIRecipeListView: View {
    
    // MARK: - Environment & Query
    /// Contexto de modelo para realizar operaciones CRUD en SwiftData (Insert/Delete)
    @Environment(\.modelContext) private var modelContext
    
    /// Consulta reactiva a SwiftData para verificar de inmediato qué recetas ya son favoritas
    @Query private var favorites: [SwiftDataRecipe]
    
    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var recipes: [Recipe] = []
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Cargando recetas...")
                        .scaleEffect(1.2)
                } else if recipes.isEmpty {
                    ContentUnavailableView(
                        "No se encuentran recetas",
                        systemImage: "fork.knife.circle",
                        description: Text("Intenta con otra búsqueda, en idioma inglés, por ejemplo: Chicken o Pasta")
                    )
                } else {
                    List(recipes) { recipe in
                        recipeRow(recipe: recipe)
                    }
                    .listStyle(.insetGrouped)
                }
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
        .task {
            if recipes.isEmpty {
                loadRecipes()
            }
        }.alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }
    
    // MARK: - Row View Helper
    @ViewBuilder
    private func recipeRow(recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            // Carga de imagen con Kingfisher
            if let url = recipe.imageUrl {
                KFImage(url)
                    .placeholder {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(recipe.category) • \(recipe.area)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                toggleFavorite(recipe: recipe)
            } label: {
                Image(systemName: isFavorite(id: recipe.id) ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite(id: recipe.id) ? .red : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
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
    
    /// Dispara la búsqueda real contra la API (NetworkManager).
    /// - Parameter query: texto a buscar; vacío trae un catálogo base (ver NetworkManager).
    private func loadRecipes(query: String = "") {
        // Activa el ProgressView del Group de arriba mientras esperamos la respuesta.
        isLoading = true
        
        // Task crea un contexto asíncrono: dentro de él SÍ podemos usar `await`,
        // sin bloquear el hilo principal ni congelar la interfaz mientras se espera.
        Task {
            do {
                // Aquí es literalmente donde "esperamos" la respuesta del servidor.
                let fetched = try await NetworkManager.shared.searchRecipes(query: query)

                // Cualquier cambio a una propiedad @State que afecte la UI debe
                // ocurrir en el hilo principal. MainActor.run lo garantiza explícitamente.
                await MainActor.run {
                    self.recipes = fetched
                    self.isLoading = false
                }
            } catch {
                // Si algo falla (sin internet, error del servidor, JSON inválido),
                // guardamos el mensaje — el .alert del body ya está escuchando errorMessage.
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Se ejecuta SOLO cuando el usuario confirma una búsqueda —al presionar Enter,
    /// o al tocar una sugerencia (.searchCompletion dispara .onSubmit automáticamente)—
    /// nunca en cada tecleo. Por eso el guardado en SQLite vive aquí.
    private func performSearch() {
        let texto = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !texto.isEmpty else { return }
        
        //SQLiteManager.shared.saveSearch(query: texto)
        SQLiteManager.shared.saveOrUpdateSearch(query: texto)
        loadRecipes(query: texto)
    }
    
    // MARK: - SwiftData Helpers
    private func isFavorite(id: String) -> Bool {
        return favorites.contains { $0.id == id }
    }
    
    private func toggleFavorite(recipe: Recipe) {
        if let existing = favorites.first(where: { $0.id == recipe.id}) {
            modelContext.delete(existing)
            print("✅ Eliminado de SwiftData")
        } else {
            let newFavorito = SwiftDataRecipe(from: recipe)
            modelContext.insert(newFavorito)
            print("✅ Insertado en SwiftData")
        }
    }
    
    
}

