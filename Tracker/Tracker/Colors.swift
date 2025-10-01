import UIKit

final class Colors {
    
    let viewBackgroundColor = UIColor.systemBackground
    
    let navigationBarTintColor: UIColor = UIColor { (traits: UITraitCollection) -> UIColor in
        switch traits.userInterfaceStyle {
        case .dark:
            return .white
        default:
            return .black
            
        }
    }
    
    let tabBarLineColor: UIColor = UIColor { (traits: UITraitCollection) -> UIColor in
        switch traits.userInterfaceStyle {
        case .light:
            return .gray
        default:
            return .black
        }
    }
    
    func trackerTintColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .black
            }
        }
    }
    
    func doneButtonBackgroundColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return UIColor(resource: .black)
            }
        }
    }
    
    func createButtonEnabledBackgroundColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return UIColor(resource: .black)
            }
        }
    }
    
    func createButtonDisabledBackgroundColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return .gray
            default:
                return UIColor(resource: .gray)
            }
        }
    }
    
    func createButtonEnabledTextColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            switch traits.userInterfaceStyle {
            case .dark:
                return .black
            default:
                return .white
            }
        }
    }
    
    func createButtonDisabledTextColor() -> UIColor {
        return UIColor { (traits) -> UIColor in
            return .white
        }
    }
    
}
