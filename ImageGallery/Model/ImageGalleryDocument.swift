//
//  Document.swift
//  ImageGallery
//
//  Created by Redemax on 5/6/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import UIKit

class ImageGalleryDocument: UIDocument {
    
    var imageGallery: ImageGallery?
    
    override func contents(forType typeName: String) throws -> Any {
        return imageGallery?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let jsonData = contents as? Data {
            imageGallery = ImageGallery(jsonData: jsonData)
        }
    }

}

