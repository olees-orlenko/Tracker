import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
//    func didchooseCategory(_ category: String)
}

final class CategoryViewController: UIViewController {
    weak var delegate: CategoryViewControllerDelegate?
}
