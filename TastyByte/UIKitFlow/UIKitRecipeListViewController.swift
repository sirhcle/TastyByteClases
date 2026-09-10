import UIKit

class UIKitRecipeListViewController: UIViewController {
    
    
    
    private let historyViewController = SearchHistoryTableViewController()
    private lazy var searchController = UISearchController(searchResultsController: historyViewController)
    
    
    /// Closure que se ejecuta al tocar el botón de cerrar.
    /// La asigna quien presenta esta pantalla (MainSelectorViewController)
    /// para saber cómo regresar al selector inicial.
    var onClose: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSearchController()
    }
    
    private func setupUI() {
        title = "Recetas (UIKit)"
        view.backgroundColor = .systemBackground
        
        // Botón para regresar al selector inicial, ya que la barra de
        // navegación externa se oculta mientras estamos en este flujo.
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        
    }
    
    
    @objc private func closeTapped() {
        onClose?()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = true
        
        searchController.showsSearchResultsController = true
        searchController.searchBar.placeholder = "Buscar receta (ej. Chicken, Pasta)..."
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Sugerencias de historial bajo el buscador: al tocar una sugerencia se llena
        // el campo y se procesa como si el usuario hubiera presionado Enter con ese texto.
        
        historyViewController.onSelectSuggestion = { [weak self] texto in
            self?.searchController.searchBar.text = texto
            self?.handleSearchSubmitted(texto)
            self?.searchController.isActive = false
        }
    }
    
    private func handleSearchSubmitted(_ query: String) {
        let texto = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return }
        
        // Guardar la búsqueda en SQLite e UserDefaults
        
        SQLiteManager.shared.saveOrUpdateSearch(query: texto)
        
        // Refrescamos la lista de sugerencias de inmediato, para que la próxima vez
        // que se toque el campo ya aparezca esta búsqueda como la más reciente.
        historyViewController.reloadSuggestions()
    }
    

}

extension UIKitRecipeListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // Aquí SÍ reaccionamos a cada tecla, pero solo para FILTRAR lo que ya está en
        // memoria (allHistory) — nunca para guardar en SQLite ni disparar una búsqueda.
        // Guardar sigue pasando únicamente al confirmar (ver searchBarSearchButtonClicked).
        let texto = searchController.searchBar.text ?? ""
        historyViewController.filter(by: texto)
    }
    
    
}

extension UIKitRecipeListViewController: UISearchBarDelegate {
    
    /// Se llama cuando el usuario presiona el botón "Buscar"/Enter del teclado.
    /// Aquí, y solo aquí, se confirma y guarda la búsqueda.
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let texto = searchBar.text else { return }
        handleSearchSubmitted(texto)
        searchController.isActive = false
    }
}
