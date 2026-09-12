import SwiftUI
import SwiftData
import Kingfisher

// MARK: - SwiftUIFavoritesView
/// Vista que lista las recetas guardadas en la base de datos local usando SwiftData y la macro @Query.
struct SwiftUIFavoritesView: View {
    
    // MARK: - Environment & Query
    @Environment(\.modelContext) private var modelContext
    
    /// Consulta reactiva automática ordenada por fecha de creación descendentemente
    @Query(sort: \SwiftDataRecipe.createdAt, order: .reverse)
    private var favoriteRecipes: [SwiftDataRecipe]
    
    var body: some View {
        NavigationStack {
            Group {
                if favoriteRecipes.isEmpty {
                    ContentUnavailableView(
                        "Sin Favoritos",
                        systemImage: "heart.slash",
                        description: Text("Guarda recetas tocando el icono de corazón en el catálogo.")
                    )
                } else {
                    List {
                        ForEach(favoriteRecipes) { recipe in
                            favoriteRow(recipe: recipe)
                        }
                        .onDelete(perform: deleteFavorite)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Favoritos (SwiftData)")
            .toolbar {
                if !favoriteRecipes.isEmpty {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Row View
    @ViewBuilder
    private func favoriteRow(recipe: SwiftDataRecipe) -> some View {
        HStack(spacing: 12) {
            if let url = recipe.imageUrl {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                
                Text("\(recipe.category) • \(recipe.area)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Delete Handler
    private func deleteFavorite(at offsets: IndexSet) {
        for index in offsets {
            let itemToDelete = favoriteRecipes[index]
            modelContext.delete(itemToDelete)
        }
    }
}

/*#Preview {
    SwiftUIFavoritesView()
}*/
