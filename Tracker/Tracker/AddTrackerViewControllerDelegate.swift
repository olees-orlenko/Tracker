import UIKit

protocol AddTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(tracker: Tracker, title: String)
    func removeTrackerRecord()
}
