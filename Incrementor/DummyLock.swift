//
//  DummyLock.swift
//  testapp
//
//  Created by andrew shishkov on 8/26/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

/// does nothing, can be helpful when the syncronization is unnecessary
class DummyLock: Lock {
    func lock() {
    }
    
    func tryLock() -> Bool {
        return true
    }
    
    func unlock() {
    }
}
