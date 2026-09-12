import UIKit
import SwiftUI
import SwiftData

class MainSelectorViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TastyByte 🍳"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Selecciona el framework de interfaz que deseas explorar:"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let uikitButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Flujo UIKit (Core Data)"
        config.baseBackgroundColor = .systemOrange
        return UIButton(configuration: config)
    }()

    private let swiftuiButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Flujo SwiftUI (SwiftData)"
        config.baseBackgroundColor = .systemBlue
        return UIButton(configuration: config)
    }()
    
    private let darkModeSwitchContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()
    
    private let darkModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Modo Oscuro (UserDefaults):"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let darkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        return toggle
    }()

    private let mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupActions()
        
        ///EJEMPLO DE USO DE NETWORK MANAGER
        /*Task {
            do {
                let recetas = try await NetworkManager.shared.searchRecipes(query: "")
                print("✅ Se encontraron \(recetas.count) recetas")
                
                for receta in recetas.prefix(5) {
                    print("🍽️ \(receta.title) — \(receta.category) / \(receta.area)")
                }
                
            } catch {
                print("❌ Error al buscar recetas: \(error.localizedDescription)")
            }
        }*/
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPreferences()
    }
    
    
    // MARK: - SETUP UI
    
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        // Armar contenedor de Modo Oscuro
        darkModeSwitchContainer.addArrangedSubview(darkModeLabel)
        darkModeSwitchContainer.addArrangedSubview(darkModeSwitch)
        
        mainStackView.addArrangedSubview(titleLabel)
        mainStackView.addArrangedSubview(subtitleLabel)
        mainStackView.addArrangedSubview(UIView())
        mainStackView.addArrangedSubview(uikitButton)
        mainStackView.addArrangedSubview(swiftuiButton)
        mainStackView.addArrangedSubview(UIView())
        mainStackView.addArrangedSubview(darkModeSwitchContainer)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            uikitButton.heightAnchor.constraint(equalToConstant: 60),
            swiftuiButton.heightAnchor.constraint(equalToConstant: 60),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    // MARK: - Acciones e interoperabilidad
    private func setupActions() {
        uikitButton.addTarget(self, action: #selector(openUIKitFlow), for: .touchUpInside)
        swiftuiButton.addTarget(self, action: #selector(openSwiftUIFlow), for: .touchUpInside)
        darkModeSwitch.addTarget(self, action: #selector(toggleDarkMode), for: .valueChanged)
    }
    
    private func loadPreferences() {
        let isDarkMode = UserDefaultsManager.shared.isDarkModeEnabled
        darkModeSwitch.isOn = isDarkMode
        applyTheme(isDarkMode: isDarkMode)
        print(FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!)
    }
    
    @objc private func toggleDarkMode() {
        let isEnabled = darkModeSwitch.isOn
        UserDefaultsManager.shared.isDarkModeEnabled = isEnabled
        applyTheme(isDarkMode: isEnabled)
    }
    
    private func applyTheme(isDarkMode: Bool) {
        if let windowScene = view.window?.windowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
            }
        }
    }
    
    /// Abre la versión UIKit empujándola en el UINavigationController
    @objc private func openUIKitFlow() {
        let catalogVC = UIKitRecipeListViewController()
        catalogVC.tabBarItem = UITabBarItem(title: "Recetas", image: UIImage(systemName: "book.fill"), tag: 0)
        catalogVC.onClose = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        /*let favoritesVC = UIKitFavoritesViewController()
        favoritesVC.tabBarItem = UITabBarItem(title: "Favoritos", image: UIImage(systemName: "heart.fill"), tag: 1)
        favoritesVC.onClose = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }*/

        // IMPORTANTE: cada pestaña necesita su propio UINavigationController.
        // Si no, el navigationItem.searchController de catalogVC nunca se muestra,
        // porque la barra de navegación visible sería la del UITabBarController,
        // no la de cada pantalla individual.
        let catalogNav = UINavigationController(rootViewController: catalogVC)
        
        //let favoritesNav = UINavigationController(rootViewController: favoritesVC)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [catalogNav, /*favoritesNav*/]
        tabBarController.title = "UIKit Flow"

        // Ocultamos la barra de navegación EXTERNA (la de MainSelectorViewController)
        // porque cada tab ya trae la suya propia (catalogNav / favoritesNav).
        // Sin esto, se verían dos barras de navegación apiladas.
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
    /// ABRE LA VERSIÓN SWIFTUI MEDIANTE UIHOSTINGCONTROLLER (INTEROPERABILIDAD)
    @objc private func openSwiftUIFlow() {
        let swiftUIView = SwiftUIRecipeTabContainer()
            .modelContainer(SwiftDataManager.shared.container)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        navigationController?.pushViewController(hostingController, animated: true)
    }
    

}


// MARK: - SwiftUIRecipeTabContainer
/// Vista auxilar de SwiftUI que agrupa el Catálogo y la pantalla de Favoritos mediante un TabView.
struct SwiftUIRecipeTabContainer: View {
    var body: some View {
        TabView {
            SwiftUIRecipeListView()
                .tabItem {
                    Label("Recetas", systemImage: "book.fill")
                }
            
            /*SwiftUIFavoritesView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }*/
        }
    }
}
