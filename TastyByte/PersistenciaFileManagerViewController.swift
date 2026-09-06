import UIKit

class PersistenciaFileManagerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nombreArchivo = "nota.txt"

        // 1. Verificar que no existe todavía
        print("¿Existe antes de guardar? \(archivoExiste(nombreArchivo: nombreArchivo))")

        // 2. Guardar contenido
        guardarArchivo(texto: "Esta es mi primera nota persistida en disco.", nombreArchivo: nombreArchivo)

        // 3. Verificar que ahora sí existe
        print("¿Existe después de guardar? \(archivoExiste(nombreArchivo: nombreArchivo))")

        // 4. Leerlo de vuelta
        if let contenido = leerArchivo(nombreArchivo: nombreArchivo) {
            print("Contenido leído: \(contenido)")
        }
    }
    
    func obtenerCarpetaDocuments() -> URL {
        return FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
    }
    
    func guardarArchivo(texto: String, nombreArchivo: String) {
        let url = obtenerCarpetaDocuments().appendingPathComponent(nombreArchivo)
        
        do {
            try texto.write(to: url, atomically: true, encoding: .utf8)
            print("✅ Archivo guardado en: \(url.path)")
        } catch {
            print("❌ Error al guardar archivo: \(error.localizedDescription)")
        }
    }
    
    func leerArchivo(nombreArchivo: String) -> String? {
        let url = obtenerCarpetaDocuments().appendingPathComponent(nombreArchivo)
        
        do {
            let contenido = try String(contentsOf: url, encoding: .utf8)
            return contenido
        } catch {
            print("⚠️ No se pudo leer el archivo (¿existe?): \(error.localizedDescription)")
            return nil
        }
    }
    
    func archivoExiste(nombreArchivo: String) -> Bool {
        let url = obtenerCarpetaDocuments().appendingPathComponent(nombreArchivo)
        return FileManager.default.fileExists(atPath: url.path)
    }

    

}
