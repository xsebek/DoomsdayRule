public struct Date {
    public let day: Int
    public let month: Month
    public let year: Year
    
    public init(day: Int, month: Month, year: Year) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    public func pretty() -> String {
        return "\(day) \(month) \(year)"
    }
    
    // MARK: Random date
    
    public enum Level: Comparable {
        case month, year, century
    }
    
    public func random(dayIn level: Level) -> Date {
        var newDay: Int = self.day
        var newMonth: Month = self.month
        var newYear: Year = self.year
        if (level >= .century) {
            let thisCentury = (year.number / 100) * 100
            let randomYear = (thisCentury...thisCentury+99).randomElement()!
            newYear = Year(number: randomYear)
        }
        if (level >= .year) {
            let randomMonth = Month.allCases.randomElement()
            newMonth = randomMonth!
        }
        newDay = (1...daysInMonth(newMonth, newYear)).randomElement()!
        return Date(day: newDay, month: newMonth, year: newYear)
    }
    
    
    // MARK: Validity
    
    public static let firstGregorianYear = Year(number: 1583)
    
    public func isValid() -> Bool {
        return year > Date.firstGregorianYear && day < daysInMonth(month, year)
    }
    
    // MARK: Distances
    
    public struct DateDistance {
        public let found: Date
        public let forward: Bool
        public let monthDistances: Dictionary<Month, Int>
        public let days: Int
        
        public init(found: Date, forward: Bool, monthDistances: Dictionary<Month, Int>) {
            self.found = found
            self.forward = forward
            self.monthDistances = monthDistances
            self.days = (forward ? 1 : -1) *  monthDistances.map{ $0.1 }.reduce(0,+)
        }
    }
    
    public func toNearest(_ monthDays: Dictionary<Month, Int>) -> DateDistance {
        precondition(!monthDays.isEmpty, "It does not make sense to measure distance to nothing!")
        let down = downToNearest(monthDays)
        guard let up = upToNearest(monthDays) else {
            return down!
        }
        guard let down = down else {
            return up
        }
        return (abs(down.days) <= abs(up.days)) ? down : up
    }
    
    func downToNearest(_ monthDays: Dictionary<Month, Int>) -> DateDistance? {
        if let monthDay = monthDays[month], monthDay > day {
            var downMonths = monthDays
            downMonths.removeValue(forKey: month)
            return downToNearest(downMonths)
        }
        if let monthDay = monthDays[month] {
            return DateDistance(
                found: Date(day: monthDay, month: month, year: year),
                forward: true,
                monthDistances: [month: day - monthDay]
            )
        }
        var m = month
        var total = Dictionary<Month, Int>()
        // skip over preceding months, updating total distance
        while (!monthDays.keys.contains(m)) {
            guard let newM = Month(rawValue: m.rawValue - 1) else {
                return nil
            }
            total[m] = (m == month) ? day : daysInMonth(m, year)
            m = newM
        }
        let d: Int = monthDays[m]!
        
        total[m] = daysInMonth(m, year) - d
        return DateDistance(
            found: Date(day: d, month: m, year: year),
            forward: true,
            monthDistances: total
        )
    }
    
    func upToNearest(_ monthDays: Dictionary<Month, Int>) -> DateDistance? {
        if let monthDay = monthDays[month], monthDay < day {
            var downMonths = monthDays
            downMonths.removeValue(forKey: month)
            return downToNearest(downMonths)
        }
        if let monthDay = monthDays[month] {
            return DateDistance(
                found: Date(day: monthDay, month: month, year: year),
                forward: true,
                monthDistances: [month: day - monthDay]
            )
        }
        var m = month
        var total = Dictionary<Month, Int>()
        // skip over following months, updating total distance
        while (!monthDays.keys.contains(m)) {
            guard let newM = Month(rawValue: m.rawValue + 1) else {
                return nil
            }
            total[m] = daysInMonth(m, year)
            m = newM
        }
        let d: Int = monthDays[m]!
        total[m] = d
        return DateDistance(
            found: Date(day: d, month: m, year: year),
            forward: true,
            monthDistances: total
        )
    }
}
