//
//  FeedStoreSpecsCoreData.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 10/10/23.
//

import XCTest
import EssentialFeed

extension XCTestCase {
	@discardableResult
	func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache insertion")
		var insertionError: Error?
		sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionResult in
            if case let Result.failure(error) = receivedInsertionResult {
                insertionError = error
            }
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return insertionError
	}

	@discardableResult
	func deleteCache(from sut: FeedStore) -> Error? {
		let exp = expectation(description: "Wait for cache deletion")
		var deletionError: Error?
		sut.deleteCachedFeed { receivedDeletionResult in
            if case let Result.failure(error) = receivedDeletionResult {
                deletionError = error
            }
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return deletionError
	}

    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
		expect(sut, toRetrieve: expectedResult, file: file, line: line)
	}

	func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedStore.RetrieveResult, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "Wait for cache retrieval")

		sut.retrieve { retrievedResult in
			switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
			     (.failure, .failure):
				break

            case let (.success(.some(expectedCache)), .success(.some(retrievedCache))):
                XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file: file, line: line)
                XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)

			default:
				XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
			}

			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)
	}
}
