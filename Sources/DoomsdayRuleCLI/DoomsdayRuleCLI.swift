//
//  DoomsdayRuleCLI.swift
//  
//
//  Created by Ondřej Šebek on 01.06.2023.
//

import Foundation
import ArgumentParser
import Rainbow
import DoomsdayRule

@main
struct DoomsdayRuleCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Doomsday algorithm command line trainer.",
        discussion: DoomsdayRuleCLI.replHelp)
    
    @Option(name: .shortAndLong,
            help: "The range of random dates [M|Y|C|A] - this month/year/century or any.",
            transform: parseRange)
    var range: DoomsdayRule.Date.Level?
    
    static func parseRange(_ text: String) throws -> DoomsdayRule.Date.Level {
        switch (text) {
        case "A": return .any
        case "C": return .century
        case "Y": return .year
        case "M": return .month
        default: throw DoomsdayCLIError.parseError("Could not parse '\(text)' range.")
        }
    }
    
    func run() {
        signal(SIGINT) {_ in
            print()
            Foundation.exit(0)
        }

        do {
            try repl()
        } catch {
            print("Error occurred: \(error)")
            Foundation.exit(1)
        }
    }
    
    func repl() throws {
        while (true) {
            queryRandomDate()
        }
    }
    
    static var replHelp: String = """
        You will be prompted to calculate the day of the week for a given date.
        
        Input your guess as a number 0 to 6 (Sunday to Saturday) and hit Enter.
        You can also use 1 to 7 (Monday to Sunday).
        
        If you would like to know the answer press '?' and hit Enter.
        For more detailed step by step answer use "??", "???" and "????".
        
        You can quit at any time using SIGKILL (Ctrl+C), EOF (Ctrl+D) or "q"/"quit".
        
        To see this message again in REPL type 'h' and hit Enter. GL, HF!
        """
    
    func queryRandomDate() {
        let randomDay = today().random(dayIn: range ?? .year)
        let found = DoomsdayRule.FindWeekday(date: randomDay)
        print("Which day of the week", timeIs(of: randomDay) + ":", randomDay.pretty().blue)
        while (true) {
            print("> ", terminator: "")
            if let line = readLine() {
                if (handleResponse(line, answer: found, for: randomDay)) {
                    print("")
                    break
                }
            } else {
                stop()
            }
        }
    }
    
    func handleResponse(_ line: String, answer: DoomsdayRule.FindWeekday, for date: DoomsdayRule.Date) -> Bool {
        if (line.isEmpty) {
            print("Please input a weekday number 0-6".dim)
            return false
        }
        if (["q", "quit"].contains(line)) {
            stop()
        }
        if (["h", "help"].contains(line)) {
            print(DoomsdayRuleCLI.replHelp)
            return false
        }
        if (line.allSatisfy{ $0 == "?" }) {
            showAnswer(answer, level: line.count, for: date)
            return true
        }
        if let number = Int(line),
           let weekday = WeekDay(rawValue: number == 7 ? 0 : number) // don't count modulo 7 for player
        {
            if (weekday == answer.result) {
                print("Correct!".green, "The weekday", timeIs(of: date), "\(weekday)".green + ".")
                return true
            } else {
                print("\(weekday)".red, "is wrong. Try again.")
            }
        } else {
            print("Could not parse input! Please input a weekday number 0-6")
        }
        return false
    }
    
    func showAnswer(_ answer: DoomsdayRule.FindWeekday, level: Int, for date: DoomsdayRule.Date) {
        if (level > 3) {
            printExplanation(answer.yearAnchor.centuryAnchor.explanation)
            print()
        }
        if (level > 2) {
            printExplanation(answer.yearAnchor.explanation)
            print()
        }
        if (level > 1) {
            printExplanation(answer.explanation)
        }
        print("The weekday", timeIs(of: date), "\(answer.result)".yellow + ".")
    }
    
    func stop() {
        print("\n=== Doomsday CLI stopped ===\n")
        Foundation.exit(0)
    }
    
    func today() -> DoomsdayRule.Date {
        let cal = Calendar(identifier: .iso8601)
        let components = cal.dateComponents([.year, .month, .day], from: Foundation.Date())
        return DoomsdayRule.Date(
            day: components.day!,
            month: Month(rawValue: components.month!)!,
            year: Year(number: components.year!)
        )
    }
    
    func timeIs(of date: DoomsdayRule.Date) -> String {
        let now = today()
        if (date < now) {
            return "was"
        } else if (date == now) {
            return "is"
        } else {
            return "will be"
        }
    }
}

enum DoomsdayCLIError: Error {
    case parseError(String)
}

func printExplanation(_ explanation: PrettyExplanation) {
    print((
        "\(explanation.title) \(color(explanation.intro)):\n" +
        explanation.steps.map{ " - \(color($0))" }.joined(separator: "\n")
    ).dim)
}

func color(part: PrettyPart) -> String {
    switch (part.tag) {
    case .Text: return part.text
    case .Math: return part.text.italic
    case .Input: return part.text.blue
    case .Answer: return part.text.yellow.italic
    }
}

func color(_ text: PrettyText) -> String {
    return text.parts.map(color(part:)).joined(separator: " ")
}
