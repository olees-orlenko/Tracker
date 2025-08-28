import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_tracker_active"),
            selectedImage: nil
        )
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistic_nonactive"),
            selectedImage: nil
        )
        let statisticNavigationController = UINavigationController(rootViewController: statisticViewController)
        viewControllers = [trackerNavigationController, statisticNavigationController]
    }
}
