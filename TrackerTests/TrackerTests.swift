import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerViewController() throws {
        let vc = TrackerViewController()
        vc.view.backgroundColor = .white
        assertSnapshot(matching: vc, as: .image, named: "TrackerViewController")
    }
    
    func testTrackerViewControllerLightTheme() throws {
        let vc = TrackerViewController()
        vc.viewDidLoad()
        vc.view.backgroundColor = .white
        let traits = UITraitCollection(userInterfaceStyle: .light)
        assertSnapshot(matching: vc, as: .image(traits: traits), named: "TrackerViewControllerLight")
    }
    
    func testTrackerViewControllerDarkTheme() throws {
        let vc = TrackerViewController()
        vc.viewDidLoad()
        vc.view.backgroundColor = .black
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        assertSnapshot(matching: vc, as: .image(traits: traits), named: "TrackerViewControllerDark")
    }
}
