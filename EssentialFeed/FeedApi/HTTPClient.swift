//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Vimal Das on 04/10/23.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
