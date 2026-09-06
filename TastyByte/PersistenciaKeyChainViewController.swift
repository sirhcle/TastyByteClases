import UIKit

class PersistenciaKeyChainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 1. Guardar un token de prueba
        guardarToken("abc123XYZ", key: "authToken")
        
        // 2. Leerlo de vuelta
        if let tokenGuardado = leerToken(key: "authToken") {
            print("Token leído: \(tokenGuardado)")
        }
        
        // 3. Eliminarlo
        eliminarToken(key: "authToken")
        
        // 4. Confirmar que ya no está
        if leerToken(key: "authToken") == nil {
            print("Confirmado: el token ya no existe")
        }
    }
    
    // MARK: - Guardar en Keychain
    
    func guardarToken(_ token: String, key: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Token guardado exitosamente en Keychain")
        } else {
            print("❌ Error al guardar en Keychain, código: \(status)")
        }
    }
    
    // MARK: - Leer de Keychain
    
    func leerToken(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true // Le decimos que SÍ queremos que nos regrese el dato
        ]
        
        var result: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            print("⚠️ No se encontró ningún valor guardado con la key: \(key)")
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func eliminarToken(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
        print("🗑️ Token eliminado de Keychain")
    }
    

}
