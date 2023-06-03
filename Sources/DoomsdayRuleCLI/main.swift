//
//  main.swift
//  
//
//  Created by Ondřej Šebek on 01.06.2023.
//
import Foundation

let tool = DoomsdayRuleCLI()

signal(SIGINT) {_ in
    tool.stop()
}

do {
    try tool.run()
} catch {
    print("Error occurred: \(error)")
}
