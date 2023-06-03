//
//  Algorithm.swift
//  
//
//  Created by Ondřej Šebek on 01.06.2023.
//

/// Find the day of the week for given date using the year anchor and a mnemonic.
public struct FindWeekday {
    public let date: Date
    public let mnemonics: Mnemonic
    
    public let yearAnchor: FindYearAnchor
    public let distanceToDoomsday: Date.DateDistance
    public let increment: WeekDay
    public let result: WeekDay
    
    public init(date: Date, mnemonics: Mnemonic? = nil) {
        self.date = date
        self.mnemonics = mnemonics ?? mnemonic(isLeap: date.year.isLeap())
        self.yearAnchor = FindYearAnchor(year: date.year)
        self.distanceToDoomsday = date.toNearest(self.mnemonics)
        self.increment = WeekDay(daysSinceSunday: distanceToDoomsday.days)
        self.result = yearAnchor.result + increment
    }
    
    public func pretty(withYearAnchor year: Bool = false, withCenturyAnchor century: Bool = false) -> String {
        return (year ? yearAnchor.pretty(withPrettyCentury: century) + "\n\n" : "")
            + """
            Find the weekday. Starting with date \(date.pretty()):
             - note the year anchor A = \(yearAnchor.result)
             - find the nearest doomsday D = \(distanceToDoomsday.found.pretty())
             - the date is \(distanceToDoomsday.days) days from doomsday
             - so the increment is I = \(distanceToDoomsday.days) ≡ \(increment.rawValue) ≡ \(increment)
             - adding it to the year anchor we get (A + I) = \(yearAnchor.result.rawValue + increment.rawValue)\
             ≡ \(result.rawValue) ≡ \(result)
            """
    }
}

// MARK: - Anchor day

/// Find the century anchor for gregorian calendar.
///
/// Every 400 years, the anchor is `Tuesday`.
///
/// Each following century retards it by two, which is the same as advancing by five.
/// As a result the century anchors repeat `Tuesday`, `Sunday`, `Friday`, `Wednesday` and again `Tuesday`, ...
public struct FindCenturyAnchor {
    public let year: Year
    /// The 0-indexed century number, i.e first two digits.
    public let century: Int
    /// The anchor repeats every four hundred years.
    public let fourCenturyIndex: Int
    /// The distance of this years anchor from century anchor.
    public let increment: WeekDay
    /// The computed `WeekDay` anchor of the given century.
    public let result: WeekDay
    
    public init(year: Year) {
        self.year = year
        self.century = year.number / 100
        self.fourCenturyIndex = century % 4
        self.increment = WeekDay(daysSinceSunday: fourCenturyIndex * 5)
        self.result = WeekDay.Tuesday + increment
    }
    
    public func pretty() -> String {
        return """
            Find the century anchor. Starting with year \(year):
             - take the century C = \(century)  (indexed from 0 as all things should be)
             - which has index F = \(century) % 4 = \(fourCenturyIndex) in a four century cycle
             - the resulting increment I = (F * -2) ≡ (F * 5) = \(fourCenturyIndex * 5) ≡ \(increment.rawValue) ≡ \(increment)
             - add Tuesday and get the result (Tuesday + I) ≡ \(WeekDay.Tuesday.rawValue + increment.rawValue) ≡ \(result)
            """
    }
}

/// Find the years Doomsday using the century anchor.
public struct FindYearAnchor {
    public let year: Year
    /// The last two digits of the year.
    public let yearInCentury: Int
    /// The anchor of the first year in the century. For example the year 2000 is `Tuesday`.
    public let centuryAnchor: FindCenturyAnchor
    /// The raw distance of this years anchor from century anchor.
    public let incrementRaw: Int
    /// The distance of this years anchor from century anchor expressed modulo 7 as a `Weekday`.
    public let increment: WeekDay
    /// The computed `WeekDay` anchor of the given year.
    public let result: WeekDay
    
    public init(year: Year) {
        self.year = year
        self.yearInCentury = year.number % 100
        self.centuryAnchor = FindCenturyAnchor(year: year)
        self.incrementRaw = (yearInCentury + (yearInCentury / 4))
        self.increment = WeekDay(daysSinceSunday: self.incrementRaw)
        self.result = centuryAnchor.result + increment
    }
    
    public func pretty(withPrettyCentury century: Bool = false) -> String {
        return (century ? centuryAnchor.pretty() + "\n" : "")
            + """
            Find the year anchor. Starting with year \(year):
             - note the century anchor A = \(centuryAnchor.result)
             - take the last two digits Y = \(yearInCentury)
             - so the increment is I = (Y + Y/4) = \(incrementRaw) ≡ \(increment.rawValue) ≡ \(increment)
             - adding the anchor we get (A + I) = \(centuryAnchor.result.rawValue + increment.rawValue)\
             ≡ \(result.rawValue) ≡ \(result)
            """
    }
}
