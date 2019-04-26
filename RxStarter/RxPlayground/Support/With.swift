//
//  With.swift
//  RxPlayground
//
//  Created by Joshua Homann on 4/23/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import Foundation

@discardableResult public func with<T>(_ item: T, update: (inout T) throws -> Void) rethrows -> T {
    var copy = item
    try update(&copy)
    return copy
}
