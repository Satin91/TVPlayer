//
//  Double.swift
//  TVPlayer
//
//  Created by Артур Кулик on 26.12.2023.
//

import Foundation

extension Double {
    func stringSecondsFormat() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour,.minute,.second]
        let stringValue = formatter.string(from: self) ?? "n/a"
        return stringValue
    }
}
