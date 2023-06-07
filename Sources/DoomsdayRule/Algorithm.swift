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
            + explanation.description
    }
    
    public var explanation: PrettyExplanation {
        let daysSum = {
            if (distanceToDoomsday.monthDistances.count == 1) { return "" }
            else { return distanceToDoomsday.monthDistances.map{"\($0.value)"}.joined(separator: " + ") + " = " }
        }()
        return PrettyExplanation(
            title: "Find the weekday.",
            intro: ["Starting with date", PrettyPart(date.pretty(), .Input)],
            steps: [
                step("note the year anchor",
                     "A = \(yearAnchor.result)"
                    ),
                step("find the nearest doomsday",
                     "D = \(distanceToDoomsday.found.pretty())"
                    ),
                [ "the date is",
                  PrettyPart("\(daysSum)\(distanceToDoomsday.days)", .Math),
                  "days from doomsday"
                ],
                step("so the increment is",
                     "I = \(distanceToDoomsday.days) ≡ \(increment.rawValue) ≡ \(increment)"
                    ),
                answer(
                    "adding it to the year anchor we get",
                    "(A + I) = \(yearAnchor.result.rawValue + increment.rawValue) ≡ \(result.rawValue) ≡",
                    "\(result)"
                )
            ]
        )
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
        return explanation.description
    }
    
    public var explanation: PrettyExplanation {
        return PrettyExplanation(
            title: "Find the century anchor.",
            intro: ["Starting with year", PrettyPart("\(year)", .Input)],
            steps: [
                step("take the century digits", "C = \(century)"),
                [ "which has index",
                  PrettyPart("F = \(century) % 4 = \(fourCenturyIndex)", .Math),
                  "in a four century cycle"
                ],
                step("the resulting increment is",
                     "I = (F * -2) ≡ (F * 5) = \(fourCenturyIndex * 5) ≡ \(increment.rawValue) ≡ \(increment)"),
                answer("add Tuesday and get the result",
                  "(Tuesday + I) ≡ \(WeekDay.Tuesday.rawValue + increment.rawValue) ≡",
                  "\(result)")
            ]
        )
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
        return (century ? centuryAnchor.pretty() + "\n\n" : "") + explanation.description
    }
    
    public var explanation: PrettyExplanation {
        return PrettyExplanation(
            title: "Find the year anchor.",
            intro: ["Starting with year", PrettyPart("\(year)", .Input)],
            steps: [
                step("note the century anchor", "A = \(centuryAnchor.result)"),
                step("take the last two digits", "Y = \(yearInCentury)"),
                step("so the increment is", "I = (Y + Y/4) = \(incrementRaw) ≡ \(increment.rawValue) ≡ \(increment)"),
                answer("adding the anchor we get",
                  "(A + I) = \(centuryAnchor.result.rawValue + increment.rawValue) ≡ \(result.rawValue) ≡",
                  "\(result)")
            ]
        )
    }
}

// MARK: - Pretty explanation

public struct PrettyExplanation: CustomStringConvertible {
    public let title: String
    public let intro: PrettyText
    public let steps: [PrettyText]
    
    public var description: String {
        return "\(title) \(intro):\n" + steps.map{" - \($0.description)"}.joined(separator: "\n")
    }
}

func step(_ note: String, _ equation: String) -> PrettyText {
    return [
        PrettyPart(note, .Text),
        PrettyPart(equation, .Math)
    ]
}

func answer(_ note: String, _ equation: String, _ result: String) -> PrettyText {
    return [
        PrettyPart(note, .Text),
        PrettyPart(equation, .Math),
        PrettyPart(result, .Answer)
    ]
}

public struct PrettyText: CustomStringConvertible, ExpressibleByArrayLiteral {
    public var parts: [PrettyPart]

    public init(parts: [PrettyPart]) {
        self.parts = parts
    }
    
    public typealias ArrayLiteralElement = PrettyPart
    public init(arrayLiteral elements: PrettyPart...) {
        parts = elements
    }
    
    public var description: String {
        return parts.map{ $0.description }.joined(separator: " ")
    }
}

public struct PrettyPart: ExpressibleByStringInterpolation, CustomStringConvertible {
    public var text: String
    public var tag: PrettyTextTag
    
    public init(_ text: String, _ tag: PrettyTextTag) {
        self.text = text
        self.tag = tag
    }
    
    public typealias StringLiteralType = String
    public init(stringLiteral: String) {
        self.text = stringLiteral
        self.tag = .Text
    }
    
    public var description: String {
        return text
    }
}

public enum PrettyTextTag {
    /// Normal text with no modifier.
    case Text
    /// Used for parts of original question, e.g. the year of the date.
    case Input
    /// Formatted equation.
    case Math
    /// Highlighted answer to the question.
    case Answer
}
