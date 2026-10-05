import Combine
import Kingfisher
import UIKit

/// Lista de favoritos en UIKit. Comparte `FavoritesViewModel` con el catálogo,
/// así un corazón y un borrado se ven en las dos pestañas.
class UIKitFavoritesViewController: UIViewController {
    private let viewModel: FavoritesViewModel
    private var cancellables = Set<AnyCancellable>()
    /// Copia publicada por Combine. `@Published` avisa en `willSet`, antes de cambiar la propiedad.
    private var displayedFavorites: [Recipe] = []

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let emptyLabel = UILabel()

    var onClose: (() -> Void)?

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("UIKitFavoritesViewController se crea en código")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favoritos"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecipeListCell.self, forCellReuseIdentifier: RecipeListCell.reuseID)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = "Sin favoritos.\nGuarda recetas tocando el corazón en el catálogo."
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        viewModel.$favorites
            .sink { [weak self] favorites in
                self?.render(favorites)
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.presentError(message)
            }
            .store(in: &cancellables)

        viewModel.load()
    }

    @objc private func closeTapped() {
        onClose?()
    }

    private func render(_ favorites: [Recipe]) {
        displayedFavorites = favorites
        let isEmpty = favorites.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.viewModel.dismissError()
        })
        present(alert, animated: true)
    }
}

extension UIKitFavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedFavorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecipeListCell.reuseID, for: indexPath) as! RecipeListCell
        let recipe = displayedFavorites[indexPath.row]
        cell.configure(with: recipe, isFavorite: true) { [weak self] in
            self?.viewModel.remove(id: recipe.id)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.remove(id: displayedFavorites[indexPath.row].id)
    }
}
