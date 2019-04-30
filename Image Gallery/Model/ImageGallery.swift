//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import Foundation

struct ImageGallery {
    private(set) var title: String = ""
    private(set) var images = [ImageGalleryItem]()
    
    var count: Int {
        return images.count
    }
    
    mutating func removeItem(at index: Int) {
        images.remove(at: index)
    }
    
    mutating func addItem(at index: Int, with url: URL) {
        let item = ImageGalleryItem(url: url)
        images.insert(item, at: index)
    }
    
    mutating func moveItem(at sourceIndex: Int, to destinationIndex: Int){
        let removeItem = images[sourceIndex]
        images.remove(at: sourceIndex)
        images.insert(removeItem, at: destinationIndex)
    }
    
    mutating func renameTitle(with title: String) {
        self.title = title
    }
    
    init(name: String, images: [ImageGalleryItem] = []) {
        self.title = name
        self.images = images
    }
}
