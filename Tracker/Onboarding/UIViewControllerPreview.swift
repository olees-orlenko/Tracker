import SwiftUI
import UIKit

struct UIViewControllerPreview<ViewController: UIViewController>: View {
    let viewController: ViewController
    
    init(@ViewBuilder viewControllerBuilder: @escaping () -> ViewController) {
        self.viewController = viewControllerBuilder()
    }
    
    var body: some View {
        OnboardingPreview()
    }
}

struct OnboardingPreview: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> OnboardingViewController {
        let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return onboardingVC
    }
    
    func updateUIViewController(_ uiViewController: OnboardingViewController, context: Context) {
    }
}
