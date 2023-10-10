//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Vimal Das on 04/10/23.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error> 

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
