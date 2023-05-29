public enum WeekDay: Int {
    case Sunday = 0
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    
    init(daysSinceSunday: Int) {
        let r = daysSinceSunday % 7
        self = WeekDay(rawValue: r >= 0 ? r : r + 7)!
    }
}
