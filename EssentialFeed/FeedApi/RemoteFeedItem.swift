//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Vimal Das on 07/10/23.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
