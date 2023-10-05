//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 05/10/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedvaluesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _,_,error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedvaluesRepresentation()))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        
        URLProtocolStub.observerRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = NSError(domain: "any error", code: 1)
        
        let receivedError = resultError(for: nil, response: nil, error: requestError)
        
        XCTAssertEqual(receivedError as NSError?, requestError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        let anyData = Data("any data".utf8)
        let anyError = NSError(domain: "any error", code: 0)
        let nonHTTPURLResponse = URLResponse(url: anyURL(),
                                             mimeType: nil,
                                             expectedContentLength: 0,
                                             textEncodingName: nil)
        let anyHTTPResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        XCTAssertNotNil(resultError(for: nil, response: nil, error: nil))
        XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse, error: nil))
        XCTAssertNotNil(resultError(for: nil, response: anyHTTPResponse, error: nil))
        XCTAssertNotNil(resultError(for: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultError(for: anyData, response: nil, error: anyError))
        XCTAssertNotNil(resultError(for: nil, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: nil, response: anyHTTPResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: nonHTTPURLResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: anyHTTPResponse, error: anyError))
        XCTAssertNotNil(resultError(for: anyData, response: nonHTTPURLResponse, error: nil))
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultError(for data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
                
        let exp = expectation(description: "wait for load completion")
        let sut = makeSUT(file: file, line: line)
        
        var receivedError: Error?
        
        sut.get(from: anyURL()) { (result) in
            switch result {
            case let .failure(error):
                receivedError = error
                
            default:
                XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }

    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestOberserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observerRequests(observer: @escaping (URLRequest) -> Void) {
            requestOberserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestOberserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestOberserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
