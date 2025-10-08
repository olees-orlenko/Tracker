import Foundation
import UIKit

func uiColorEqual(_ a: UIColor, _ b: UIColor, tolerance: CGFloat = 0.001) -> Bool {
    var ra: CGFloat = 0, ga: CGFloat = 0, ba: CGFloat = 0, aa: CGFloat = 0
    var rb: CGFloat = 0, gb: CGFloat = 0, bb: CGFloat = 0, ab: CGFloat = 0
    guard a.getRed(&ra, green: &ga, blue: &ba, alpha: &aa),
          b.getRed(&rb, green: &gb, blue: &bb, alpha: &ab) else {
        return a == b
    }
    return abs(ra - rb) <= tolerance &&
    abs(ga - gb) <= tolerance &&
    abs(ba - bb) <= tolerance &&
    abs(aa - ab) <= tolerance
}
