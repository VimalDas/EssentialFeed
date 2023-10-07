//
//  ValidateFeedCacheuseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 08/10/23.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheuseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueFeedImage(), uniqueFeedImage()]
        let local = models.map { LocalFeedImage(id: $0.id,
                                                   description: $0.description,
                                                   location: $0.location,
                                                   url: $0.url) }
        return (models, local)
    }
    
    private func uniqueFeedImage() -> FeedImage {
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
