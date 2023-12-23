//
//  Observer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 23.12.2023.
//

import Foundation

//class Observable: NSObject {
//    @objc dynamic var value: TVChannel
//    
//    init(value: TVChannel) {
//        self.value = value
//    }
//}

class Observer {
    var kvoToken: NSKeyValueObservation?
    var value: TVChannel
    
    init(value: TVChannel) {
        self.value = value
    }
    func observe(_ onChange: @escaping (TVChannel) -> Void) {
        kvoToken = value.observe(\.isFavorite, options: .new) { (value, change) in
            guard let favorite = change.newValue else { return }
            onChange(value)
            print("Change value on \(value.name)")
        }
    }
    
    deinit {
        kvoToken?.invalidate()
    }
}
