//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 08/10/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmprtCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected empty result, got \(result)")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
