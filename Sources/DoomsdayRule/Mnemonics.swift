//
//  Mnemonics.swift
//  
//
//  Created by Ondřej Šebek on 01.06.2023.
//

public typealias Mnemonic = Dictionary<Month, Int>

public let mnemonicEven: Mnemonic = [
    Month.April: 4,
    Month.June: 6,
    Month.August: 8,
    Month.October: 10,
    Month.December: 12,
]

public let mnemonic9to5: Mnemonic = [
    Month.May: 9,
    Month.September: 5,
]

public let mnemonic711: Mnemonic = [
    Month.July: 11,
    Month.November: 7,
]

public let mnemonicCommon: Mnemonic = [
    Month.January: 3,
    Month.February: 28,
]

public let mnemonicLeap: Mnemonic = [
    Month.January: 4,
    Month.February: 29,
]

public let mnemonicDoom: Mnemonic = [
    Month.March: 0 // last day of February
]

public func mnemonic(isLeap: Bool) -> Mnemonic {
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
