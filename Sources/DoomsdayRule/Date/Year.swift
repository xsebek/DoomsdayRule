public struct Year: Comparable {
    public let number: Int
    
    public init(number: Int) {
        self.number = number
    }

    public func isLeap() -> Bool {
        let div4 = number % 4 == 0
        let div100 = number % 100 == 0
        let div400 = number % 400 == 0
        return div4 && (!div100 || div400)
    }
    
    public static func < (lhs: Year, rhs: Year) -> Bool {
        return lhs.number < rhs.number
    }
}

extension Year: CustomStringConvertible {
    public var description: String {
        return "\(number)"
    }
}

/// How many days are in given month, when it is (not) leap year.
///
/// This overload just makes it easier to work with the `Year` structure.
func daysInMonth(_ month: Month, _ year: Year) -> Int {
    return daysInMonth(month, isLeapYear: year.isLeap())
}
