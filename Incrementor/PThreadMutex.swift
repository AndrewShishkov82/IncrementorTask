//
//  PThreadMutex.swift
//  testapp
//
//  Created by andrew shishkov on 8/25/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

import Foundation

public final class PThreadMutex: Lock, DefaultConstructible {
    private var mutex: pthread_mutex_t
    
    public convenience init() {
        self.init(isRecursive: false)
    }

    /// by default is not recursive
    public init(isRecursive: Bool = false) {
        mutex = pthread_mutex_t()
        
        var attr = pthread_mutexattr_t()
        defer {
            pthread_mutexattr_destroy(&attr)
        }
        
        guard pthread_mutexattr_init(&attr) == 0 else {
            preconditionFailure()
        }
        
        if isRecursive {
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        } else {
            pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_NORMAL)
        }

        guard pthread_mutex_init(&mutex, &attr) == 0 else {
            preconditionFailure()
        }
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    public func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    public func tryLock() -> Bool {
        return pthread_mutex_trylock(&mutex) == 0
    }
    
    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
