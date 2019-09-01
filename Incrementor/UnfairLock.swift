//
//  UnfairLock.swift
//  testapp
//
//  Created by andrew shishkov on 8/26/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

import Foundation

// in most cases the fastest thing. Like a bullet) if you try to use it correctly.
@available(OSX 10.12, iOS 10, tvOS 10, watchOS 3, *)
public final class UnfairLock: Lock {
    public init() {
    }
    
    private var mutex = os_unfair_lock()
    
    public func lock() {
        os_unfair_lock_lock(&mutex)
    }
    
    public func tryLock() -> Bool {
        return os_unfair_lock_trylock(&mutex)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(&mutex)
    }
}
