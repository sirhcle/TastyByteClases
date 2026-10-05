import Combine
import Kingfisher
import UIKit

class UIKitRecipeListViewController: UIViewController {

    /// Inyectado desde `MainSelectorViewController`. La pantalla no lo construye.
    private let viewModel: RecipeListViewModel
    /// Corazones. Compartido con la pestaña de favoritos.
    private let favoritesViewModel: FavoritesViewModel
    /// Suscripciones de Combine. Si no se guardan, el `sink` se cancela al salir de `bind()`.
    private var cancellables = Set<AnyCancellable>()
    /// Copia de las recetas que ya publicó el ViewModel.
    /// `@Published` avisa en `willSet`, antes de cambiar la propiedad, así que la tabla no puede leer `viewModel.recipes` dentro del `sink`.
    private var displayedRecipes: [Recipe] = []
    /// Identificadores favoritos que ya publicó `FavoritesViewModel`. Misma razón que `displayedRecipes`.
    private var favoriteIDs: Set<String> = []

    private let historyViewController = SearchHistoryTableViewController()
    private lazy var searchController = UISearchController(searchResultsController: historyViewController)

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()

    /// Closure que se ejecuta al tocar el botón de cerrar.
    /// La asigna quien presenta esta pantalla (MainSelectorViewController)
    /// para saber cómo regresar al selector inicial.
    var onClose: (() -> Void)?

    /// - Parameter viewModel: Estado de la lista, ya conectado a los casos de uso.
    /// - Parameter favoritesViewModel: Estado de los corazones. No abre SwiftData desde aquí.
    init(viewModel: RecipeListViewModel, favoritesViewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        self.favoritesViewModel = favoritesViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("UIKitRecipeListViewController se crea en código")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSearchController()
        bind()
        // Primera petición a TheMealDB. Ocurre aquí, no al crear el ViewModel.
        viewModel.loadIfNeeded()
        favoritesViewModel.load()
    }

    private func setupUI() {
        title = "Recetas (UIKit)"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        tableView.dataSource = self
        tableView.register(RecipeListCell.self, forCellReuseIdentifier: RecipeListCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        loadingIndicator.color = .systemOrange
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = "No se encuentran recetas.\nIntenta con otra búsqueda, en inglés, por ejemplo: Chicken o Pasta"
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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

        historyViewController.onSelectSuggestion = { [weak self] texto in
            self?.searchController.searchBar.text = texto
            self?.handleSearchSubmitted(texto)
            self?.searchController.isActive = false
        }
        historyViewController.onAppear = { [weak self] in
            let text = self?.searchController.searchBar.text ?? ""
            self?.viewModel.refreshSuggestions(matching: text)
        }
    }

    /// UIKit no observa `@Published` solo. Combine avisa y esta pantalla actualiza tabla, indicador y alerta.
    /// El `sink` recibe el valor nuevo. No se vuelve a leer `viewModel.recipes` aquí: `@Published` dispara en `willSet`,
    /// cuando la propiedad todavía tiene el valor anterior.
    private func bind() {
        Publishers.CombineLatest(viewModel.$recipes, viewModel.$isLoading)
            .sink { [weak self] recipes, isLoading in
                self?.renderList(recipes: recipes, isLoading: isLoading)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.presentError(message)
            }
            .store(in: &cancellables)

        favoritesViewModel.$favorites
            .sink { [weak self] favorites in
                self?.favoriteIDs = Set(favorites.map(\.id))
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        favoritesViewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.presentError(message)
            }
            .store(in: &cancellables)

        viewModel.$suggestions
            .sink { [weak self] suggestions in
                self?.historyViewController.show(suggestions)
            }
            .store(in: &cancellables)
    }

    /// Pinta con los valores que entregó Combine, no con las propiedades del ViewModel.
    private func renderList(recipes: [Recipe], isLoading: Bool) {
        displayedRecipes = recipes

        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }

        let showEmpty = recipes.isEmpty && !isLoading
        emptyLabel.isHidden = !showEmpty
        tableView.isHidden = isLoading || showEmpty
        tableView.reloadData()
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.viewModel.dismissError()
            self?.favoritesViewModel.dismissError()
        })
        present(alert, animated: true)
    }

    /// Confirmar (Enter o una sugerencia) guarda el término y pide recetas.
    /// Cada tecla solo pide sugerencias, en `updateSearchResults`.
    private func handleSearchSubmitted(_ query: String) {
        let texto = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !texto.isEmpty else { return }

        viewModel.searchText = texto
        viewModel.submitSearch()
    }
}

extension UIKitRecipeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedRecipes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeListCell.reuseID, for: indexPath) as! RecipeListCell
        let recipe = displayedRecipes[indexPath.row]
        cell.configure(with: recipe, isFavorite: favoriteIDs.contains(recipe.id)) { [weak self] in
            self?.favoritesViewModel.toggle(recipe)
        }
        return cell
    }
}

extension UIKitRecipeListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let texto = searchController.searchBar.text ?? ""
        viewModel.refreshSuggestions(matching: texto)
    }
}

extension UIKitRecipeListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let texto = searchBar.text else { return }
        handleSearchSubmitted(texto)
        searchController.isActive = false
    }
}

final class RecipeListCell: UITableViewCell {
    static let reuseID = "RecipeListCell"

    private let thumbnail = UIImageView()
    private let titleLabel = UILabel()
    private let detailLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    /// La celda no sabe qué es un favorito. Avisa al controlador, que llama al ViewModel.
    private var onFavoriteTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 10
        thumbnail.tintColor = .secondaryLabel

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2

        detailLabel.font = .preferredFont(forTextStyle: .subheadline)
        detailLabel.textColor = .secondaryLabel

        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        favoriteButton.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(textStyle: .title3),
            forImageIn: .normal
        )

        let textStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [thumbnail, textStack, favoriteButton])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            thumbnail.widthAnchor.constraint(equalToConstant: 60),
            thumbnail.heightAnchor.constraint(equalToConstant: 60),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("RecipeListCell se crea en código")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.kf.cancelDownloadTask()
        thumbnail.image = nil
        onFavoriteTapped = nil
    }

    func configure(with recipe: Recipe, isFavorite: Bool, onFavoriteTapped: @escaping () -> Void) {
        self.onFavoriteTapped = onFavoriteTapped
        let symbol = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: symbol), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .systemGray

        titleLabel.text = recipe.title
        detailLabel.text = "\(recipe.category) • \(recipe.area)"

        guard let imageURL = recipe.imageURL, let url = URL(string: imageURL) else {
            thumbnail.image = UIImage(systemName: "photo")
            return
        }

        thumbnail.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
    }

    @objc private func favoriteTapped() {
        onFavoriteTapped?()
    }
}
