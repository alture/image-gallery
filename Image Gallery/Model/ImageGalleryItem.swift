//
//  ImageGalleryItem.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import Foundation

struct ImageGalleryItem {
    private(set) var url: URL?
    init(url: URL) {
        self.url = url
    }
}
