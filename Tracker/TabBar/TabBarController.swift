import UIKit

final class TabBarController: UITabBarController {
    
    private let colors = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tabBarLine = UIView(frame: CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1))
        tabBarLine.backgroundColor = colors.tabBarLineColor
        tabBar.addSubview(tabBarLine)
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
