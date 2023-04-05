//
//  Publisher+helper.swift
//  SwiftUI+MVVM+CombineFeedback+PoC
//
//  Created by Tomislav Juric-Arambasic on 31.03.2023..
//

import Combine

extension Publisher where Self.Failure == Never {
    public func assignNoRetain<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
        object?[keyPath: keyPath] = value
    }
  }
}
