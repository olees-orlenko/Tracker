import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_tracker_title", comment: "Title for the Tracker tab"),
            image: UIImage(named: "tab_tracker_active"),
            selectedImage: nil
        )
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_statistic_title", comment: "Title for the Statistics tab"),
            image: UIImage(named: "tab_statistic_nonactive"),
            selectedImage: nil
        )
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        viewControllers = [trackerNavigationController, statisticNavigationController]
    }
}
