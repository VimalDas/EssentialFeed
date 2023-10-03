//
//  EssentialFeedTests.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 04/10/23.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedUrl = URL(string: "https://a-url.com")
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() {}
    
    var requestedUrl: URL?
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesnotReuestDataFromUrl() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedUrl)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        
        XCTAssertNotNil(client.requestedUrl)
    }
}
