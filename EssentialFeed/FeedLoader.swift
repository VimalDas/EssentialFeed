//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Vimal Das on 04/10/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
