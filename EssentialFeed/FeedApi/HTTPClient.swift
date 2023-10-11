//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Vimal Das on 04/10/23.
//

import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL, completion: @escaping (Result) -> Void)
}
