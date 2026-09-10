import UIKit

class UIKitRecipeListViewController: UIViewController {
    
    
    
    private let historyViewController = SearchHistoryTableViewController()
    private lazy var searchController = UISearchController(searchResultsController: historyViewController)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
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
    
    private func handleSearchSubmitted(_ query: String) { }
    

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
