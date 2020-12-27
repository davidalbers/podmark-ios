import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    @Environment(\.managedObjectContext) var moc

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: FoldersView().environment(\.managedObjectContext, moc))
            self.window = window
            
            window.makeKeyAndVisible()
        }
    }
}

