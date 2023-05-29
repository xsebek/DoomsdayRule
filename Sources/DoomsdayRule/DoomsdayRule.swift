public struct DoomsdayRule {
    
    // MARK: Algorithm
    
    /// Find the day of the week for given date using the year anchor and a mnemonic.
    struct FindWeekday {
        let date: Date
        let mnemonics: Mnemonic
        
        let yearAnchor: FindYearAnchor
        let distanceToDoomsday: Date.DateDistance
        let increment: WeekDay
        let result: WeekDay
        
        init(date: Date, mnemonics: Mnemonic? = nil) {
            self.date = date
            self.mnemonics = mnemonics ?? mnemonic(isLeap: date.year.isLeap())
            self.yearAnchor = FindYearAnchor(year: date.year)
            self.distanceToDoomsday = date.toNearest(self.mnemonics)
            self.increment = WeekDay(daysSinceSunday: distanceToDoomsday.days)
            self.result = WeekDay(daysSinceSunday: yearAnchor.result.rawValue + increment.rawValue)
        }
    }
    
    // MARK: - Anchor day
    
    /// Find the century anchor for gregorian calendar.
    ///
    /// Every 400 years, the anchor is `Tuesday`.
    ///
    /// Each following century retards it by two, which is the same as advancing by five.
    /// As a result the century anchors repeat `Tuesday`, `Sunday`, `Friday`, `Wednesday` and again `Tuesday`, ...
    struct FindCenturyAnchor {
        let year: Year
        /// The 0-indexed century number, i.e first two digits.
        let century: Int
        /// The anchor repeats every four hundred years.
        let fourCenturyIndex: Int
        /// The distance of this years anchor from century anchor.
        let increment: Int
        /// The computed `WeekDay` anchor of the given century.
        let result: WeekDay
        
        init(year: Year) {
            self.year = year
            self.century = year.number / 100
            self.fourCenturyIndex = century % 4
            self.increment = (fourCenturyIndex * 5) % 7
            self.result = WeekDay(daysSinceSunday: increment + WeekDay.Tuesday.rawValue)
        }
    }
    
    /// Find the years Doomsday using the century anchor.
    struct FindYearAnchor {
        let year: Year
        /// The last two digits of the year.
        let yearInCentury: Int
        /// The anchor of the first year in the century. For example the year 2000 is `Tuesday`.
        let centuryAnchor: FindCenturyAnchor
        /// The distance of this years anchor from century anchor.
        let increment: Int
        /// The computed `WeekDay` anchor of the given year.
        let result: WeekDay
        
        init(year: Year) {
            self.year = year
            self.yearInCentury = year.number % 100
            self.centuryAnchor = FindCenturyAnchor(year: year)
            self.increment = (yearInCentury + (yearInCentury / 4))
            self.result = WeekDay(daysSinceSunday: centuryAnchor.result.rawValue + increment)
        }
    }
    
    // MARK: - Mnemonics
    public typealias Mnemonic = Dictionary<Month, Int>
    
    public static let mnemonicEven: Mnemonic = [
        Month.April: 4,
        Month.June: 6,
        Month.August: 8,
        Month.October: 10,
        Month.December: 12,
    ]
    
    public static let mnemonic9to5: Mnemonic = [
        Month.May: 9,
        Month.September: 5,
    ]
    
    public static let mnemonic711: Mnemonic = [
        Month.July: 11,
        Month.November: 7,
    ]
    
    public static let mnemonicCommon: Mnemonic = [
        Month.January: 3,
        Month.February: 28,
    ]
    
    public static let mnemonicLeap: Mnemonic = [
        Month.January: 4,
        Month.February: 29,
    ]

    public static let mnemonicDoom: Mnemonic = [
        Month.March: 0 // last day of February
    ]
    
    public static func mnemonic(isLeap: Bool) -> Mnemonic {
        let mnemonics = [
            mnemonicEven,
            mnemonic9to5,
            mnemonic711,
            //mnemonicDoom,
            isLeap ? mnemonicLeap : mnemonicCommon,
        ]
        var result = Mnemonic()
        for m in mnemonics {
            result.merge(m) { (_, new) in new }
        }
        return result
    }
}
