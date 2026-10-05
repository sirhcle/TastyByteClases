import UIKit

// MARK: - SearchHistoryTableViewController
/// Pantalla de sugerencias bajo el buscador.
/// No abre SQLite: muestra el arreglo que le pasa `UIKitRecipeListViewController`.
class SearchHistoryTableViewController: UITableViewController {

    /// Sugerencias ya filtradas por `SuggestSearchesUseCase`.
    private var suggestions: [SearchEntry] = []

    /// Al tocar una fila. El catálogo llena el campo y confirma la búsqueda.
    var onSelectSuggestion: ((String) -> Void)?
    /// Al aparecer, para pedir de nuevo las sugerencias (por ejemplo, tras guardar una búsqueda).
    var onAppear: (() -> Void)?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "suggestionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onAppear?()
    }

    /// Reemplaza las filas con lo que publicó el ViewModel.
    func show(_ entries: [SearchEntry]) {
        suggestions = entries
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
