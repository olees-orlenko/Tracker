import UIKit

struct Tracker {
    var id: UUID
    var name: String
    var color: UIColor
    var emoji: String
    var schedule: [Week]
}

enum Week: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var localizedString: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "Monday")
        case .tuesday: return NSLocalizedString("tuesday", comment: "Tuesday")
        case .wednesday: return NSLocalizedString("wednesday", comment: "Wednesday")
        case .thursday: return NSLocalizedString("thursday", comment: "Thursday")
        case .friday: return NSLocalizedString("friday", comment: "Friday")
        case .saturday: return NSLocalizedString("saturday", comment: "Saturday")
        case .sunday: return NSLocalizedString("sunday", comment: "Sunday")
        }
    }
    
    var bitValue: Int {
        switch self {
        case .sunday:    return 0
        case .monday:    return 1
        case .tuesday:   return 2
        case .wednesday: return 3
        case .thursday:  return 4
        case .friday:    return 5
        case .saturday:  return 6
        }
    }
    
    init?(calendarWeekday: Int) {
        switch calendarWeekday {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
    
    static func changeScheduleValue(for schedule: [Week]) -> Int16 {
        var scheduleValue: Int16 = 0
        for day in schedule {
            scheduleValue |= Int16(1 << day.bitValue)
        }
        return scheduleValue
    }
    
    static func changeScheduleArray(from value: Int16) -> [Week] {
        var schedule: [Week] = []
        for day in Week.allCases {
            if value & Int16(1 << day.bitValue) != 0 {
                schedule.append(day)
            }
        }
        return schedule
    }
}
