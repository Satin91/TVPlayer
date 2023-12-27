//
//  Observer.swift
//  TVPlayer
//
//  Created by Артур Кулик on 23.12.2023.
//

import Foundation
import UIKit

class Observable<T> {
  typealias Listener = (T) -> ()
  private var listeners: [Listener] = []
  init(_ v: T) {
    value = v
  }
  var value: T {
    didSet {
      for l in listeners { l(value) } }
  }
  func bind(_ to: @escaping Listener) {
    listeners.append(to)
    to(value)
  }
    
    func send(_ value: T) {
        self.value = value
    }
  func subscribe(l: @escaping Listener) {
    listeners.append(l)
  }
}
