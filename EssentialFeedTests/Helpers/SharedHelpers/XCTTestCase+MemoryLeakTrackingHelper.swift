//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 05/10/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
