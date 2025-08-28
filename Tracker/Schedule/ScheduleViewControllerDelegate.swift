protocol ScheduleViewControllerDelegate: AnyObject {
    func didUpdateSchedule(selectedDays: [Week])
}
