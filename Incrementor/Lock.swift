//
//  Lock.swift
//  testapp
//
//  Created by andrew shishkov on 8/26/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

public protocol Lock: class {
    /// holds the lock
    func lock()
    
    /// trying to hold the lock
    /// - Returns: true if the lock is in-use and false otherwise
    func tryLock() -> Bool
    
    /// frees the lock
    func unlock()
}

extension Lock {
    /// Performs closure inside the lock
    /// - Parameter closure: task to execute
    /// - Returns: result of the closure
    @inlinable
    public func synchronize<R>(closure: () throws -> R) rethrows -> R {
        lock()
        defer {
            unlock()
        }
        return try closure()
    }
    
    /// returns immediately if the lock is in-use
    /// - Parameter closure: task to execute
    /// - Returns: result of the closure
    @inlinable
    public func tryToSynchronize<R>(closure: () throws -> R) rethrows -> R? {
        guard tryLock() else {
            return nil
        }
        defer {
            unlock()
        }
        return try closure()
    }
}
