//
//  Observer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 23.12.2023.
//

import Foundation
import UIKit

protocol Observable {
    associatedtype T
    func send(_ object: T)
}

class Observer<T: NSObject>: Observable {
    
    var kvoToken: NSKeyValueObservation?
    var value: T
    
    func send(_ object: T) {
        self.value = object
    }
    
    init(value: T) {
        self.value = value
    }
    
    func observe<Property>(for keyPath: KeyPath<T, Property>, onChange: @escaping (T, Property) -> Void) {
        kvoToken = value.observe(keyPath, options: .new, changeHandler: { change, value in
            guard let value = value.newValue else { return }
            onChange(change, value)
        })
    }
    
    deinit {
        kvoToken?.invalidate()
    }
}

class ObservableArray<T>: Observable {
    
    var value: [T] {
        didSet {
            guard var toValue = self.toValue else { return }
            bind(to: &toValue)
        }
    }
    
    private var toValue: ObservableArray?
    
    init(value: [T]) {
        self.value = value
    }
    
    var comp: (([T]) -> Void)?
    
    func subscribe(onChange: ([T]) -> Void) {
        
        onChange(value)
    }
    
    func send(_ object: [T]) {
        value = object
        comp?(object)
    }
    
    func bind(to: inout ObservableArray) {
        to = self
        comp?(value)
    }
}
