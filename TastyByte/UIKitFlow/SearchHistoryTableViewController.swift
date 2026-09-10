import UIKit

// MARK: - SearchHistoryTableViewController
/// Pantalla de sugerencias que se muestra debajo del buscador (como searchResultsController
/// de UISearchController). Lista las últimas búsquedas guardadas en SQLite; al tocar una,
/// avisa a quien la presenta (vía `onSelectSuggestion`) para llenar el campo y buscar.
class SearchHistoryTableViewController: UITableViewController {
    
    // MARK: - Properties

    /// Historial completo tal cual viene de SQLite (sin filtrar).
    private var allHistory: [SearchItem] = []

    /// Subconjunto de allHistory que se muestra actualmente (ya filtrado y limitado a 5).
    private var suggestions: [SearchItem] = []
    
    /// Closure que se ejecuta cuando el usuario toca una sugerencia.
    /// Quien crea este controlador (UIKitRecipeListViewController) decide qué hacer con el texto.
    var onSelectSuggestion: ((String) -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "suggestionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recargamos cada vez que la pantalla aparece, por si se guardó una búsqueda nueva
        // desde la última vez (por ejemplo, después de buscar algo y volver a tocar el campo).
        
        reloadSuggestions()
    }
    
    // MARK: - Data

    /// Recarga el historial completo desde SQLite (sin filtro). Se llama automáticamente
    /// en viewWillAppear, y también manualmente justo después de guardar una búsqueda nueva
    /// (ver UIKitRecipeListViewController), para que la lista se actualice de inmediato.
    func reloadSuggestions() {
        allHistory = SQLiteManager.shared.fetchSearchHistory()
        applyFilter(currentFilterText)
    }
    
    /// Texto con el que se está filtrando actualmente (vacío = sin filtro, muestra las últimas 5).
    private var currentFilterText: String = ""

    /// Filtra el historial ya cargado en memoria según lo que el usuario va escribiendo.
    /// NO vuelve a consultar SQLite — solo filtra `allHistory`, que ya está en memoria.
    func filter(by text: String) {
        currentFilterText = text
        applyFilter(text)
    }
    
    private func applyFilter(_ text: String) {
        if text.isEmpty {
            suggestions = Array(allHistory.prefix(5))
        } else {
            suggestions = Array(
                allHistory
                    .filter { $0.query.localizedCaseInsensitiveContains(text) }
                    .prefix(5)
            )
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        suggestions.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionCell", for: indexPath)
        let item = suggestions[indexPath.row]
        print("🔍 Item: \(item.query) Fecha: \(item.date.formatted(date: .abbreviated, time: .shortened))")
        
        var config = cell.defaultContentConfiguration()
        config.text = item.query
        config.image = UIImage(systemName: "clock.arrow.circlepath")
        cell.contentConfiguration = config

        return cell
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = suggestions[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)

        // Avisamos hacia afuera qué texto se seleccionó; UIKitRecipeListViewController
        // decide qué hacer (llenar el searchBar y disparar la búsqueda).
        onSelectSuggestion?(item.query)
    }
}
