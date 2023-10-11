//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Vimal Das on 04/10/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>

    func load(completion: @escaping (Result) -> Void)
}
