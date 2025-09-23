import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Scene Lifecycle

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = initialViewController()
        window.makeKeyAndVisible()
    }

    // MARK: - Routing

    private func initialViewController() -> UIViewController {
        let onboardingWasShown = UserDefaults.standard.bool(forKey: "onboardingWasShown")

        if onboardingWasShown {
            return TabBarController()
        } else {
            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboardingVC.onboardingCompletionHandler = { [weak self] in
                self?.switchToMainInterface()
            }
            return onboardingVC
        }
    }

    private func switchToMainInterface() {
        let mainVC = TabBarController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()

        let transition = CATransition()
        transition.type = .fade
        transition.duration = 0.3
        window?.layer.add(transition, forKey: kCATransition)
    }
}
