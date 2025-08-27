import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
//    func updateScheduleInfo(_ selectedDays: [WeekDay],_ switchStates: [Int: Bool])
}


final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    var switchButton: [Int : Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
