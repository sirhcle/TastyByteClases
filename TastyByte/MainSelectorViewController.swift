//
//  MainSelectorViewController.swift
//  TastyByte
//
//  Created by CHRISTIAN HERNANDEZ RIVERA on 31/08/26.
//

import UIKit

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
        //uikitButton.addTarget(self, action: #selector(pushUIKit), for: .touchUpInside)
        //swiftuiButton.addTarget(self, action: #selector(pushSwiftUI), for: .touchUpInside)
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
    

}
