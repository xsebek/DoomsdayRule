//
//  DoomsdayRuleCLI.swift
//  
//
//  Created by Ondřej Šebek on 01.06.2023.
//

import Foundation
import DoomsdayRule

public final class DoomsdayRuleCLI {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        let cal = Calendar(identifier: .iso8601)
        let components = cal.dateComponents([.year, .month, .day], from: Foundation.Date())
        let today = DoomsdayRule.Date(
            day: components.day!,
            month: Month(rawValue: components.month!)!,
            year: Year(number: components.year!)
        )
        while (true) {
            queryRandomDate(today)
        }
    }
    
    public func stop() {
        print("\n=== Doomsday CLI stopped ===\n")
        exit(0)
    }
    
    public func help() {
        print("""
            Doomsday algorithm CLI trainer
            - you will be prompted to calculate the day of the week for a given date
            - input your guess as a number 0 to 6 (Sunday to Saturday) and hit Enter
            - if you would like to know the answer press '?' and hit Enter
              - for more detailed step by step answer use "??", "???" and "????"
            - you can quit at any time using SIGKILL (Ctrl+C), EOF (Ctrl+D) or "q"/"quit"
            - have fun!
            """)
    }
    
    private func queryRandomDate(_ today: DoomsdayRule.Date) {
        let randomDay = today.random(dayIn: .year)
        let found = DoomsdayRule.FindWeekday(date: randomDay)
        print("Which day of the week was: \(randomDay.pretty())")
        while (true) {
            print("> ", terminator: "")
            if let line = readLine() {
                if (handleResponse(line, forAnswer: found)) {
                    print("")
                    break
                }
            } else {
                stop()
            }
        }
    }
    
    private func handleResponse(_ line: String, forAnswer found: DoomsdayRule.FindWeekday) -> Bool {
        if (line.isEmpty) {
            print("Please input a weekday number 0-6")
            return false
        }
        if (["q", "quit"].contains(line)) {
            stop()
        }
        if (["h", "help"].contains(line)) {
            help()
            return false
        }
        if (line.allSatisfy{ $0 == "?" }) {
            showAnswer(found, level: line.count)
            return true
        }
        if let number = Int(line),
           let weekday = WeekDay(rawValue: number == 7 ? 0 : number) // don't count modulo 7 for player
        {
            if (weekday == found.result) {
                print("Correct! The weekday is \(weekday)")
                return true
            } else {
                print("\(weekday) is wrong. Try again.")
            }
        } else {
            print("Could not parse input! Please input a weekday number 0-6")
        }
        return false
    }
    
    private func showAnswer(_ answer: DoomsdayRule.FindWeekday, level: Int) {
        if (level > 1) {
            print(answer.pretty(withYearAnchor: level > 2, withCenturyAnchor: level > 3))
        }
        print("The correct weekday was \(answer.result).")
    }
}
