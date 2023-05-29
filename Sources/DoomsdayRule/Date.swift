public struct Date {
    let day: Int
    let month: Month
    let year: Year
    
    // MARK: Validity
    
    static let firstGregorianYear = Year(number: 1583)
    
    func isValid() -> Bool {
        return year > Date.firstGregorianYear && day < daysInMonth(month, year)
    }
    
    // MARK: Distances
    
    struct DateDistance {
        let found: Date
        let forward: Bool
        let monthDistances: Dictionary<Month, Int>
        let days: Int
        
        init(found: Date, forward: Bool, monthDistances: Dictionary<Month, Int>) {
            self.found = found
            self.forward = forward
            self.monthDistances = monthDistances
            self.days = (forward ? 1 : -1) *  monthDistances.map{ $0.1 }.reduce(0,+)
        }
    }
    
    func toNearest(_ monthDays: Dictionary<Month, Int>) -> DateDistance {
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
