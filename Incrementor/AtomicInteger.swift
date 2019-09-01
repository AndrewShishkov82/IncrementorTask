//
//  AtomicInteger.swift
//  testapp
//
//  Created by andrew shishkov on 8/25/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

import Foundation

/// Atomic integer generic structure. Conforms to the BinaryInteger protocol
struct AtomicInteger<Type, LockType> where Type: BinaryInteger, LockType: Lock, LockType: DefaultConstructible {
    
    typealias Magnitude = Type.Magnitude
    typealias IntegerLiteralType = Type.IntegerLiteralType
    typealias Words = Type.Words
    private var value: Type
    
    private var mutex = LockType()
    
    private func lock() {
        mutex.lock()
    }

    private func unlock() {
        mutex.unlock()
    }
    
    func get() -> Type {
        lock(); defer { unlock() }
        return value
    }
    
    mutating func set(value: Type) {
        lock(); defer { unlock() }
        self.value = value
    }
    
    func get(closure: (Type) -> ()) {
        lock(); defer { unlock() }
        closure(value)
    }
    
    mutating func set(closure: (Type) -> (Type)) {
        lock(); defer { unlock() }
        self.value = closure(value)
    }
}
// BinaryInteger Properties
extension AtomicInteger: BinaryInteger {
    var words: Type.Words {
        lock();
        defer {
            unlock()
        }
        return value.words
    }
    
    var bitWidth: Int {
        lock();
        defer {
            unlock()
        }
        return value.bitWidth
    }
    
    var trailingZeroBitCount: Int {
        lock();
        defer {
            unlock()
        }
        return value.trailingZeroBitCount
    }
    
    var magnitude: Type.Magnitude {
        lock();
        defer {
            unlock()
        }
        return value.magnitude
    }
    
    static var isSigned: Bool { return Type.isSigned }
    
    // initializers
    
    init() {
        value = Type()
    }
    
    init(integerLiteral value: AtomicInteger.IntegerLiteralType) {
        self.value = Type(integerLiteral: value)
    }
    
    init<T>(_ source: T) where T : BinaryInteger {
        value = Type(source)
    }
    
    init(_ source: Int) {
        value = Type(source)
    }
    
    init<T>(clamping source: T) where T : BinaryInteger {
        value = Type(clamping: source)
    }
    
    init?<T>(exactly source: T) where T : BinaryInteger {
        guard let value = Type(exactly: source) else { return nil }
        self.value = value
    }
    
    init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        value = Type(truncatingIfNeeded: source)
    }
    
    init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        guard let value = Type(exactly: source) else { return nil }
        self.value = value
    }
    
    init<T>(_ source: T) where T : BinaryFloatingPoint {
        value = Type(source)
    }
}

// Private helpers
extension AtomicInteger {
    /// casts value of an Other type to the Type
    private static func valueOf<Other>(other: Other) -> Type where Other : BinaryInteger {
        if let other = other as? AtomicInteger {
            return other.get()
        }
        return Type(other)
    }
    
    /// performes the closure in a syncronized manner and returnes the resulting value
    private func perform<Result, Other>(closure: (Type, Type) -> (Result), with other: Other) -> Result where Other : BinaryInteger {
        lock();
        defer {
            unlock()
        }
        return closure(value, AtomicInteger.valueOf(other: other))
    }
    
    ///  performs the closure in a synchronized manner and stores the resulting value
    mutating private func setResultOf<Other>(closure: (Type, Type) -> (Type), with other: Other) where Other : BinaryInteger {
        self.set(value: closure(self.value, AtomicInteger.valueOf(other: other)))
    }
}

// Math Functions
extension AtomicInteger {
    static func % (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 % $1 }, with: rhs)
        return self.init(value)
    }
    
    static func %= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 % $1 }, with: rhs)
    }
    
    static func & (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 & $1 }, with: rhs)
        return self.init(value)
    }
    
    static func &= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 & $1 }, with: rhs)
    }
    
    static func * (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 * $1 }, with: rhs)
        return self.init(value)
    }
    
    static func *= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 * $1 }, with: rhs)
    }
    
    static func + (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 + $1 }, with: rhs)
        return self.init(value)
    }
    static func += (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 + $1 }, with: rhs)
    }
    
    static func - (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 - $1 }, with: rhs)
        return self.init(value)
    }
    
    static func -= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 - $1 }, with: rhs)
    }
    
    static func / (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 / $1 }, with: rhs)
        return self.init(value)
    }
    
    static func /= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 / $1 }, with: rhs)
    }
    
    static func ^ (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 ^ $1 }, with: rhs)
        return self.init(value)
    }
    
    static func ^= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 ^ $1 }, with: rhs)
    }
    
    static func | (lhs: AtomicInteger, rhs: AtomicInteger) -> AtomicInteger {
        let value = lhs.perform(closure: { $0 | $1 }, with: rhs)
        return self.init(value)
    }
    
    static func |= (lhs: inout AtomicInteger, rhs: AtomicInteger) {
        lhs.setResultOf(closure: { $0 | $1 }, with: rhs)
    }
    
    static prefix func ~ (x: AtomicInteger) -> AtomicInteger {
        x.lock(); defer { x.unlock() }
        return self.init(x.value)
    }
}

// Shifting Operator Functions
extension AtomicInteger {
    static func << <RHS>(lhs:  AtomicInteger<Type, LockType>, rhs: RHS) -> AtomicInteger where RHS : BinaryInteger {
        let value = lhs.perform(closure: { $0 << $1 }, with: rhs)
        return self.init(value)
    }
    
    static func <<= <RHS>(lhs: inout AtomicInteger, rhs: RHS) where RHS : BinaryInteger {
        lhs.setResultOf(closure: { $0 << $1 }, with: rhs)
    }
    
    static func >> <RHS>(lhs: AtomicInteger, rhs: RHS) -> AtomicInteger where RHS : BinaryInteger {
        let value = lhs.perform(closure: { $0 >> $1 }, with: rhs)
        return self.init(value)
    }
    
    static func >>= <RHS>(lhs: inout AtomicInteger, rhs: RHS) where RHS : BinaryInteger {
        lhs.setResultOf(closure: { $0 >> $1 }, with: rhs)
    }
}

// Comparing Functions
extension AtomicInteger {
    static func != <Other>(lhs: AtomicInteger, rhs: Other) -> Bool where Other : BinaryInteger {
        return lhs.perform(closure: { $0 != $1 }, with: rhs)
    }
    
    static func != (lhs: AtomicInteger, rhs: AtomicInteger) -> Bool {
        return lhs.perform(closure: { $0 != $1 }, with: rhs)
    }

    static func < <Other>(lhs: AtomicInteger<Type, LockType>, rhs: Other) -> Bool where Other : BinaryInteger {
        return lhs.perform(closure: { $0 < $1 }, with: rhs)
    }
    
    static func <= (lhs: AtomicInteger, rhs: AtomicInteger) -> Bool {
        return lhs.perform(closure: { $0 <= $1 }, with: rhs)
    }
    
    static func == <Other>(lhs: AtomicInteger, rhs: Other) -> Bool where Other : BinaryInteger {
        return lhs.perform(closure: { $0 == $1 }, with: rhs)
    }
    
    static func > <Other>(lhs: AtomicInteger, rhs: Other) -> Bool where Other : BinaryInteger {
        return lhs.perform(closure: { $0 > $1 }, with: rhs)
    }
    
    static func > (lhs: AtomicInteger, rhs: AtomicInteger) -> Bool {
        return lhs.perform(closure: { $0 > $1 }, with: rhs)
    }
    
    static func >= (lhs: AtomicInteger, rhs: AtomicInteger) -> Bool {
        return lhs.perform(closure: { $0 >= $1 }, with: rhs)
    }
    
    static func >= <Other>(lhs: AtomicInteger, rhs: Other) -> Bool where Other : BinaryInteger {
        return lhs.perform(closure: { $0 >= $1 }, with: rhs)
    }
}

// Hashable
extension AtomicInteger {
    
    var hashValue: Int {
        lock(); defer { unlock() }
        return value.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        lock(); defer { unlock() }
        value.hash(into: &hasher)
    }
}
