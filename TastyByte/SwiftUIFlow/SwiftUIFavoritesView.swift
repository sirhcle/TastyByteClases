import SwiftUI
import Kingfisher

// MARK: - SwiftUIFavoritesView
/// Lista los favoritos que publica `FavoritesViewModel`.
/// No usa `@Query` ni `modelContext`: borrar llama a `remove(at:)`.
struct SwiftUIFavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    ContentUnavailableView(
                        "Sin Favoritos",
                        systemImage: "heart.slash",
                        description: Text("Guarda recetas tocando el icono de corazón en el catálogo.")
                    )
                } else {
                    List {
                        ForEach(viewModel.favorites) { recipe in
                            favoriteRow(recipe: recipe)
                        }
                        .onDelete { offsets in
                            viewModel.remove(at: offsets)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Favoritos")
            .toolbar {
                if !viewModel.favorites.isEmpty {
                    EditButton()
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )) {
                Button("OK") { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private func favoriteRow(recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
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
}
