//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Vimal Das on 08/10/23.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

