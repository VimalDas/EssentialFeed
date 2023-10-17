//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Vimal Das on 17/10/23.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
