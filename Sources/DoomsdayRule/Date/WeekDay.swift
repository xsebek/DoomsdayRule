public enum WeekDay: Int, CaseIterable {
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    
    public init(daysSinceSunday: Int) {
        let r = daysSinceSunday % 7
        self = WeekDay(rawValue: r >= 0 ? r : r + 7)!
    }
}

// MARK: Extensions

extension WeekDay: AdditiveArithmetic {
    public static func - (lhs: WeekDay, rhs: WeekDay) -> WeekDay {
        return WeekDay(daysSinceSunday: lhs.rawValue - rhs.rawValue)
    }
    
    public static func + (lhs: WeekDay, rhs: WeekDay) -> WeekDay {
        return WeekDay(daysSinceSunday: lhs.rawValue + rhs.rawValue)
    }
    
    public static var zero: WeekDay = .Sunday
    
    
}
