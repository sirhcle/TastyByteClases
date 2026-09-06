import UIKit

class PersistenciaSQLiteManagerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        SQLiteManager.shared.saveSearch(query: "hamburguesa")
        SQLiteManager.shared.saveSearch(query: "tacos")
        SQLiteManager.shared.saveSearch(query: "quesadillas sin queso o con queso")
        
        
        let historial = SQLiteManager.shared.fetchSearchHistory()
        
        for item in historial {
            print("🔍 \(item.query) — \(item.date) - \(item.id)")
        }
         */
        
        SQLiteManager.shared.deleteSearch(id: 1)
        
        let historial2 = SQLiteManager.shared.fetchSearchHistory()
        
        for item in historial2 {
            print("🔍 \(item.query) — \(item.date) - \(item.id)")
        }
    }
}
