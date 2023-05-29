import XCTest
@testable import DoomsdayRule

final class DoomsdayRuleTests: XCTestCase {
    func testDaysCount() throws {
        let daysCommon = Month.allCases.map{ daysInMonth($0) }.reduce(0, +)
        XCTAssertEqual(daysCommon, 365)
        let daysLeap = Month.allCases.map{ daysInMonth($0, isLeapYear: true) }.reduce(0, +)
        XCTAssertEqual(daysLeap, 366)
    }
    
    func testDaysCountCalendar() throws {
        let cal = Calendar.current
        let months = (1...12).map {
            cal.date(from: DateComponents(year: 2023, month: $0))!
        }
        for (myMonth, calMonth) in zip(Month.allCases, months) {
            let calDays = cal.range(of: .day, in: .month, for: calMonth)!.count
            XCTAssertEqual(daysInMonth(myMonth), calDays)
        }
    }
    
    func testLeapYear() throws {
        XCTAssert(Year(number: 2024).isLeap())
        XCTAssertFalse(Year(number: 2023).isLeap())
        XCTAssert(Year(number: 2000).isLeap())
        XCTAssertFalse(Year(number: 2100).isLeap())
    }
    
    func testLeapYearCalendar() throws {
        let cal = Calendar.current
        let myYears = (1900...2100).map{ Year(number: $0) }
        let calYears = (1900...2100).map {
            cal.date(from: DateComponents(year: $0))!
        }
        for (myYear, calYear) in zip(myYears, calYears) {
            let calLeap = 366 == cal.range(of: .day, in: .year, for: calYear)!.count
            XCTAssertEqual(
                myYear.isLeap(), calLeap,
                "\(myYear) says leap: \(myYear.isLeap()), but should be \(calLeap)"
            )
        }
    }
    
    func getRealDoomsdayWeekdays(year: Int, isLeap: Bool) -> [Int] {
        let cal = Calendar(identifier: .iso8601)
        return DoomsdayRule.mnemonic(isLeap: isLeap).map { (month, day) in
            let d = cal.date(from: DateComponents(year: year, month: month.rawValue, day: day))!
            return cal.component(.weekday, from: d)
        }
    }
    
    func testMnemonicSameWeekdayCommon() throws {
        let dates = getRealDoomsdayWeekdays(year: 2023, isLeap: false)
        XCTAssert(dates.allSatisfy{ $0 == dates[0] })
    }
    
    func testMnemonicSameWeekdayLeap() throws {
        let dates = getRealDoomsdayWeekdays(year: 2024, isLeap: true)
        XCTAssert(dates.allSatisfy{ $0 == dates[0] })
    }
    
    func testIsoWeekdays() throws {
        let cal = Calendar(identifier: .iso8601)
        let weekdays = cal.range(of: .weekday, in: .weekOfMonth, for: Date())
        XCTAssertEqual(weekdays, Range(1...7))
        let knownSaturday = DateComponents(year: 2000, month: 1, day: 1)
        let calWeekDay = cal.component(.weekday, from: cal.date(from: knownSaturday)!) - 1
        XCTAssertEqual(calWeekDay % 7, WeekDay.Saturday.rawValue)
    }
    
    func testCenturyAnchor() throws {
        // Try this century
        let doomsdays2000 = getRealDoomsdayWeekdays(year: 2000, isLeap: true)
        let centuryAnchor = DoomsdayRule.FindCenturyAnchor(year: Year(number: 2000))
        XCTAssert(doomsdays2000.allSatisfy{ ($0 - 1) % 7 == centuryAnchor.result.rawValue})
        // Try last century
        let doomsdays1900 = getRealDoomsdayWeekdays(year: 1900, isLeap: false)
        let lastCenturyAnchor = DoomsdayRule.FindCenturyAnchor(year: Year(number: 1900))
        XCTAssert(doomsdays1900.allSatisfy{ ($0 - 1) % 7 == lastCenturyAnchor.result.rawValue})
    }
    
    func calendarDoomsday(year: Int) -> Int {
        let cal = Calendar(identifier: .iso8601)
        let march1 = cal.date(from: DateComponents(year: year, month: 3, day: 1))!
        let lastFeb = cal.date(byAdding: DateComponents(day: -1), to: march1)!
        return cal.component(.weekday, from: lastFeb) - 1
    }
    
    func testYearAnchor() throws {
        for year in 1900...2100 {
            let foundDoomsday = DoomsdayRule.FindYearAnchor(year: Year(number: year))
            let myDoomsday = foundDoomsday.result
            let calDoomsday = WeekDay(rawValue: calendarDoomsday(year: year))!
            XCTAssertEqual(
                myDoomsday, calDoomsday,
                "In year \(year), the doomsday was \(calDoomsday), but calculated \(myDoomsday)"
            )
        }
    }
    
    func useCalendar(toAddDays days: Int, toYear year: Int) -> Foundation.Date {
        let cal = Calendar(identifier: .iso8601)
        let date = cal.date(from: DateComponents(year: year, month: 1, day: 1))!
        return (days == 0) ? date : cal.date(byAdding: DateComponents(day: days), to: date)!
    }
    
    func testWeekday() throws {
        let cal = Calendar(identifier: .iso8601)
        for days in 0...(365*4 + 1) {
            let date = useCalendar(toAddDays: days, toYear: 2020)
            let components = cal.dateComponents([.day, .month, .year, .weekday], from: date)
            let calWeekday = WeekDay(daysSinceSunday: components.weekday! - 1)
            let myWeekday = DoomsdayRule.FindWeekday(
                date: Date(
                    day: components.day!,
                    month: Month(rawValue: components.month!)!,
                    year: Year(number: components.year!)
                )
            )
            let dateString = date.formatted(date: .complete, time: .omitted)
            XCTAssertEqual(myWeekday.result, calWeekday, "On \(dateString), the calculated day was \(myWeekday.result)")
        }
    }
}
