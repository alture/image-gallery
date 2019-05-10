//
//  ImageGallery.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import Foundation

struct ImageGallery: Codable {
    private(set) var images = [ImageInfo]()
    
    struct ImageInfo: Codable {
        var url: URL
        init(url: URL) {
            self.url = url
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
        
    init(images: [ImageInfo]) {
        self.images = images
    }
    
    init?(jsonData: Data) {
        if let newValue = try? JSONDecoder().decode(ImageGallery.self, from: jsonData) {
            self = newValue
        } else {
            return nil
        }
    }
}
