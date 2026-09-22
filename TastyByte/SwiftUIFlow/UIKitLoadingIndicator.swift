import SwiftUI

/// Envoltura de UIActivityIndicatorView (UIKit) para poder usarlo dentro de una vista SwiftUI.
/// Este es el ejemplo más simple de interoperabilidad UIKit -> SwiftUI mediante UIViewRepresentable
/// — el sentido CONTRARIO a UIHostingController (que ya usamos para meter SwiftUI dentro de UIKit
/// en MainSelectorViewController).


struct UIKitLoadingIndicator: UIViewRepresentable {
    
    // MARK: - makeUIView
    // Se ejecuta UNA sola vez: aquí creamos el UIView de UIKit que queremos usar.
    // Es el equivalente conceptual a viewDidLoad — "constrúyeme esto una vez".
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemOrange
        indicator.startAnimating()
        return indicator
    }
    
    
    // MARK: - updateUIView
    // Se ejecuta cada vez que SwiftUI detecta un cambio de estado relacionado con esta vista.
    // Aquí no necesitamos actualizar nada dinámico (el indicador siempre gira igual),
    // así que queda vacío — pero el método es obligatorio, el protocolo lo exige.
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        //no hace nada
    }
    
    
    
    
}
