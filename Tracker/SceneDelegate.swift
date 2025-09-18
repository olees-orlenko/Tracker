import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        let onboardingWasShown = UserDefaults.standard.bool(forKey: "onboardingWasShown")
        if onboardingWasShown {
            let mainViewController = TabBarController()
            window.rootViewController = mainViewController
        } else {
            let onboardingViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboardingViewController.onboardingCompletionHandler = { [weak self] in
                let mainViewController = TabBarController()
                self?.window?.rootViewController = mainViewController
            }
            window.rootViewController = onboardingViewController
        }
        window.makeKeyAndVisible()
    }
}
