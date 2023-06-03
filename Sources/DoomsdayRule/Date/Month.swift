public enum Month: Int, Comparable, CaseIterable {
    case January = 1
    case February
    case March
    case April
    case May
    case June
    case July
    case August
    case September
    case October
    case November
    case December
    
    public static func < (lhs: Month, rhs: Month) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

/// How many days are in given month, when it is (not) leap year.
func daysInMonth(_ month: Month, isLeapYear: Bool = false) -> Int {
    switch month {
    case .January:
        return 31
    case .February:
        return isLeapYear ? 29 : 28
    case .March:
        return 31
    case .April:
        return 30
    case .May:
        return 31
    case .June:
        return 30
    case .July:
        return 31
    case .August:
        return 31
    case .September:
        return 30
    case .October:
        return 31
    case .November:
        return 30
    case .December:
        return 31
    }
}
