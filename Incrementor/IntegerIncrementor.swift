//
//  IntegerIncrementor.swift
//  testapp
//
//  Created by andrew shishkov on 8/26/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

import Foundation

public enum IncrementorError: Error {
    case InvalidArgument(reason: String)
}

/// holds an integer value, and able to increment it untill it reach the maximum value
public class IntegerIncrementor<IntType, LockType>: NSObject, NSCopying where IntType: FixedWidthInteger, LockType: Lock, LockType: DefaultConstructible {
    private var value: IntType = 0
    private var maxValue: IntType = IntType.max
    public let mutex = LockType()
    
    public override init() {
    }
    
    /// returns current integer value
    @discardableResult public func getNumber() -> IntType {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        return value
    }
    
    /// increases current value by one, when the value becomes greater than maximum value it becomes 0 again
    public func incrementNumber() {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        
        if value == maxValue {
            value = 0
        } else {
            value += 1
        }
    }
    
    /// sets the maximum value, when the maximumValue value becomes greater than value, value becomes 0
    public func setMaximumValue(_ maximumValue: IntType) throws {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        
        guard maximumValue >= 0 else {
            throw IncrementorError.InvalidArgument(reason: "maximumValue can't be negative")
        }
        
        if maximumValue < value {
            value = 0
        }
        maxValue = maximumValue
    }
    
    /// returns maximum value
    public var maximumValue: IntType {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        
        return maxValue
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = IntegerIncrementor()
        copy.value = value
        copy.maxValue = maxValue
        return copy
    }
}
