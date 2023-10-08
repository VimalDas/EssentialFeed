//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 08/10/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            feed.map { $0.toLocal }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var toLocal: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        return completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map { CodableFeedImage($0) }, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }

}

class CodableFeedStoreTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        
        CodableFeedStoreTests.setupEMptySToreState()
    }
        
    override class func tearDown() {
        super.tearDown()
        
        CodableFeedStoreTests.undoStoreSideEffects()
    }
        
    func test_retrieve_deliversEmptyOnEmprtCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectOnEmprtCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                    
                default:
                    XCTFail("Expected empty result, got \(firstResult) and \(secondResult)")
                }
                
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted succesfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted succesfully")
            
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFoundFeed, firstFoundTimestamp), .found(secondFoundFeed, secondFoundTimestamp)):
                        XCTAssertEqual(firstFoundFeed, feed)
                        XCTAssertEqual(firstFoundTimestamp, timestamp)
                        
                        XCTAssertEqual(secondFoundFeed, feed)
                        XCTAssertEqual(secondFoundTimestamp, timestamp)
                        
                    default:
                        XCTFail("Expected retrieving twice from non empty cache to deliver same found result with feed \(feed) and time stamp \(timestamp), got \(firstResult) and \(secondResult) instead")
                    }
                    
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    //MARK: - Helpers
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCacheFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
                
            case let (.found(expectedFoundFeed, expectedFoundTimestamp), .found(retrievedFoundFeed, retrievedFoundTimestamp)):
                XCTAssertEqual(expectedFoundFeed, retrievedFoundFeed)
                XCTAssertEqual(expectedFoundTimestamp, retrievedFoundTimestamp)
                                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead")
            }
            
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: CodableFeedStoreTests.testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private static func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private static func setupEMptySToreState() {
        deleteStoreArtifacts()
    }

    private static func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private static func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: CodableFeedStoreTests.testSpecificStoreURL())
    }
}
