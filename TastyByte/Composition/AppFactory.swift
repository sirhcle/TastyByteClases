import SwiftData
import UIKit

/// Grafo de dependencias de la app. `SceneDelegate` lo crea una vez y se lo pasa a la pantalla raíz.
/// Las vistas no llaman a `.shared`: piden ViewModels a este objeto.
struct AppDependencies {
    /// Contenedor de SwiftData abierto al arrancar. SwiftUI lo recibe en `.modelContainer`.
    let modelContainer: ModelContainer
    /// Modo oscuro. La pantalla de inicio solo habla con este puerto.
    let preferences: any PreferencesRepository
    private let searchHistory: any SearchHistoryRepository

    init(
        modelContainer: ModelContainer,
        preferences: any PreferencesRepository,
        searchHistory: any SearchHistoryRepository
    ) {
        self.modelContainer = modelContainer
        self.preferences = preferences
        self.searchHistory = searchHistory
    }

    /// No llama a la red. La búsqueda empieza en `loadIfNeeded()`.
    func makeRecipeListViewModel() -> RecipeListViewModel {
        RecipeListViewModel(
            searchRecipes: SearchRecipesUseCase(repository: MealDBRecipeRepository()),
            recordSearch: RecordSearchUseCase(repository: searchHistory),
            suggestSearches: SuggestSearchesUseCase(repository: searchHistory)
        )
    }

    /// Un solo repositorio SwiftData para listar, marcar y quitar.
    func makeFavoritesViewModel() -> FavoritesViewModel {
        let repository = SwiftDataFavoriteRepository(modelContainer: modelContainer)
        return FavoritesViewModel(
            listFavorites: ListFavoritesUseCase(repository: repository),
            toggleFavorite: ToggleFavoriteUseCase(repository: repository),
            removeFavorite: RemoveFavoriteUseCase(repository: repository)
        )
    }
}

/// Punto de composición. Si SwiftData no abre, devuelve una pantalla de error en lugar de cerrar la app.
enum AppFactory {
    static func makeRootViewController() -> UIViewController {
        do {
            let store = try SwiftDataManager()
            let dependencies = AppDependencies(
                modelContainer: store.container,
                preferences: UserDefaultsPreferencesRepository(),
                searchHistory: SQLiteSearchHistoryRepository(manager: .shared)
            )
            return MainSelectorViewController(dependencies: dependencies)
        } catch {
            return StartupErrorViewController(message: error.localizedDescription)
        }
    }
}

/// Se muestra solo cuando el almacén de SwiftData no pudo crearse al arrancar.
final class StartupErrorViewController: UIViewController {
    private let message: String

    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("StartupErrorViewController se crea en código")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let title = UILabel()
        title.text = "No se pudo abrir TastyByte"
        title.font = .preferredFont(forTextStyle: .title2)
        title.textAlignment = .center
        title.numberOfLines = 0

        let detail = UILabel()
        detail.text = message
        detail.font = .preferredFont(forTextStyle: .body)
        detail.textColor = .secondaryLabel
        detail.textAlignment = .center
        detail.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [title, detail])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
