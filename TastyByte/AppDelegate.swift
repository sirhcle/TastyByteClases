import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 1. Quien recibe las notificaciones mientras la app está abierta
        UNUserNotificationCenter.current().delegate = self
        
        // 2. Pedir permiso al usuario
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            print(granted ? "✅ Permiso concedido" : "❌ Permiso denegado: \(String(describing: error))")
            
            // 3. Solo si dio permiso, nos registramos para recibir remotas
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
                
        return true
    }
    
    // MARK: - Registro exitoso: aquí llega el Device Token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(token)")
        // Nota: en un proyecto real, aquí se manda `token` a tu servidor.
        // Hoy no lo necesitamos porque probamos con el Simulador directamente.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("❌ Error al registrar para notificaciones remotas: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Se llama cuando llega una notificación CON LA APP ABIERTA (en primer plano).
    /// Sin esto, las notificaciones no se muestran visualmente si la app está activa.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Se llama cuando el usuario TOCA la notificación (app en background o cerrada).
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        print("🔔 Usuario tocó la notificación: \(response.notification.request.content.body)")
        completionHandler()
        
    //TODO: EJECUTAR EN LA TERMINAL LO SIGUIENTE
        // xcrun simctl push booted com.bundleID.TastyByte /path/to/file/payload.apns
        
        /*
         file: payload.apns
         ====================
         {
           "aps": {
             "alert": {
               "title": "TastyByte 🍳",
               "body": "¡Nueva receta disponible! Toca para verla."
             },
             "sound": "default",
             "badge": 1
           }
         }
         =============================
         */
    }
}

