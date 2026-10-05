import SwiftUI
import Kingfisher

struct SwiftUIRecipeListView: View {

    /// Lo crea `MainSelectorViewController` y lo retiene `SwiftUIRecipeTabContainer`.
    /// `@ObservedObject` redibuja esta vista cuando cambian los `@Published` del ViewModel.
    @ObservedObject var viewModel: RecipeListViewModel
    /// Corazones. La vista no inserta en SwiftData: llama a `toggle`.
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                
                if viewModel.isLoading {
//                    ProgressView("Cargando recetas...")
//                        .scaleEffect(1.2)
                    VStack(spacing: 12) {
                        UIKitLoadingIndicator()
                            .frame(width: 80, height: 80, alignment: .center)
                        Text("Cargando recetas con indicator de UIKit")
                            .foregroundColor(.primary)
                    }
                    
                    
                } else if viewModel.recipes.isEmpty {
                    ContentUnavailableView(
                        "No se encuentran recetas",
                        systemImage: "fork.knife.circle",
                        description: Text("Intenta con otra búsqueda, en idioma inglés, por ejemplo: Chicken o Pasta")
                    )
                } else {
                    List(viewModel.recipes) { recipe in
                        recipeRow(recipe: recipe)
                    }
                    .listStyle(.insetGrouped)
                }
            }
        }
        .navigationTitle("Recetas (SwiftUI)")
        .searchable(text: $viewModel.searchText, prompt: "Buscar receta")
        .searchSuggestions {
            //TODO: Filtrados de búsqueda
            ForEach(viewModel.suggestions) { item in
                Text(item.query)
                    .searchCompletion(item.query)
                    .onAppear {
                        print("🔍 Item: \(item.query) Fecha: \(item.date.formatted(date: .abbreviated, time: .shortened))")
                    }
            }
        }
        .onSubmit(of: .search) {
            // Enter o una sugerencia: guarda el término y pide recetas. Cada tecla no entra aquí.
            viewModel.submitSearch()
        }
        .onChange(of: viewModel.searchText) { _, _ in
            // Cada tecla pide sugerencias. No guarda el texto.
            viewModel.refreshSuggestions(matching: viewModel.searchText)
        }
        .task {
            // Catálogo inicial. No registra historial.
            viewModel.loadIfNeeded()
            viewModel.refreshSuggestions(matching: viewModel.searchText)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil || favoritesViewModel.errorMessage != nil },
            set: { if !$0 { viewModel.dismissError(); favoritesViewModel.dismissError() } }
        )) {
            Button("OK") {
                viewModel.dismissError()
                favoritesViewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? favoritesViewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Row View Helper
    @ViewBuilder
    private func recipeRow(recipe: Recipe) -> some View {
        HStack(spacing: 12) {
            // Carga de imagen con Kingfisher
            if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
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
                favoritesViewModel.toggle(recipe)
            } label: {
                Image(systemName: favoritesViewModel.isFavorite(id: recipe.id) ? "heart.fill" : "heart")
                    .foregroundColor(favoritesViewModel.isFavorite(id: recipe.id) ? .red : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
    }
    
    
}

