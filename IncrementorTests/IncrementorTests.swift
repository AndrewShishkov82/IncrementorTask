//
//  IncrementorTests.swift
//  IncrementorTests
//
//  Created by andrew shishkov on 9/1/19.
//  Copyright © 2019 andrew shishkov. All rights reserved.
//

import XCTest
import Incrementor

class IncrementorTests: XCTestCase {
    let dispatchGroup = DispatchGroup()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// performs closure on a given dispatch queue repeatCount times
    private func async(dispatch: DispatchQueue, repeatCount: Int, closure: @escaping (DispatchQueue)->()) {
        for _ in 0 ..< repeatCount {
            dispatchGroup.enter()
            dispatch.async {
                closure(dispatch)
                self.dispatchGroup.leave()
            }
        }
    }
    
    /// check against arithmetic rules
    func testArithmeticRules() {
        let i = IntegerIncrementor<Int, PThreadMutex>()
        // check initial values
        XCTAssert(i.getNumber() == 0)
        XCTAssert(i.maximumValue == Int.max)
        
        // check that incrementNumber increases value by 1
        i.incrementNumber()
        XCTAssert(i.getNumber() == 1)
        i.incrementNumber()
        XCTAssert(i.getNumber() == 2)
        
        // check against negative maximum value
        XCTAssertThrowsError(try i.setMaximumValue(-1))
        
        // check for correct work in case of 0 maximum value
        XCTAssertNoThrow(try i.setMaximumValue(0))
        XCTAssert(i.getNumber() == 0)
        i.incrementNumber()
        XCTAssert(i.getNumber() == 0)
    }
    
    func testMutexCalls() {
        let i = IntegerIncrementor<Int8, MockLock>()
        
        i.getNumber()
        XCTAssert(i.mutex.lockCallsCount == 1)
        XCTAssert(i.mutex.unlockCallsCount == 1)
        
        XCTAssert(i.maximumValue == Int8.max)
        XCTAssert(i.mutex.lockCallsCount == 2)
        XCTAssert(i.mutex.unlockCallsCount == 2)
        
        i.incrementNumber()
        XCTAssert(i.mutex.lockCallsCount == 3)
        XCTAssert(i.mutex.unlockCallsCount == 3)
        
        XCTAssertNoThrow(try i.setMaximumValue(0))
        XCTAssert(i.mutex.lockCallsCount == 4)
        XCTAssert(i.mutex.unlockCallsCount == 4)
    }
    
    func testIncrementorMultithreading() {
        let i = IntegerIncrementor<Int, PThreadMutex>()
        let closure: (DispatchQueue)->() = { _ in i.incrementNumber() }
        async(dispatch: .global(qos: .userInitiated), repeatCount: 50, closure: closure)
        async(dispatch: .global(qos: .utility), repeatCount: 50, closure: closure)
        async(dispatch: .global(qos: .background), repeatCount: 50, closure: closure)
        async(dispatch: .global(qos: .default), repeatCount: 50, closure: closure)
        
        dispatchGroup.wait()
        XCTAssert(i.getNumber() == 200)
    }
}

/// Mock for testing number of locks/unlocks
fileprivate class MockLock: Lock, DefaultConstructible {
    var lockCallsCount = 0
    var unlockCallsCount = 0
    
    required init() {
    }
    
    func lock() {
        lockCallsCount += 1
    }
    
    func tryLock() -> Bool {
        return true
    }
    
    func unlock() {
        unlockCallsCount += 1
    }
}

