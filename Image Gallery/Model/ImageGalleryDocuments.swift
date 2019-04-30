//
//  ImageGalleryDocuments.swift
//  Image Gallery
//
//  Created by Redemax on 4/27/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import Foundation

struct ImageGalleryDocuments {
    private(set) var imageGalleries = [ImageGallery]()
    private(set) var removedDocuments = [ImageGallery]()
    
    var count: Int {
        return imageGalleries.count
    }
    
    mutating func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return imageGalleries.count
        case 1:
            return removedDocuments.count
        default:
            return 0
        }
    }
    
    mutating func getTitleOfDocumentAtIndexPath(_ indexPath: IndexPath) -> String? {
        var currentTitle: String? = nil
        switch indexPath.section {
        case 0:
            currentTitle = imageGalleries[indexPath.item].title
        case 1:
            currentTitle = removedDocuments[indexPath.item].title
        default:
            break
        }
        
        return currentTitle
    }
    
    mutating func imageGalleryAtIndexPath(_ indexPath: IndexPath) -> ImageGallery? {
        if indexPath.section == 0 {
            return imageGalleries[indexPath.item]
        } else {
            return removedDocuments[indexPath.item]
        }
    }
    
    mutating func addNewImageGallery() {
        let imageGalley = ImageGallery(name: "Image Gallery")
        imageGalleries.append(imageGalley)
    }
    
    mutating func removeImageGalleyAtIndexPath(_ indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            removedDocuments.append(imageGalleries.remove(at: indexPath.item))
        case 1:
            removedDocuments.remove(at: indexPath.item)
        default:
            break
        }
    }
    
    mutating func renameTitleAtIndexPath(_ indexPath: IndexPath, with newTitle: String) {
        if indexPath.section == 0 {
            imageGalleries[indexPath.item].renameTitle(with: newTitle)
        }
    }
    
    mutating func updateImageGallery(_ imageGallery: ImageGallery, at index: Int) {
        imageGalleries[index] = imageGallery
    }
    
    mutating func restoreImageGalleryAtIndexPath(_ indexPath: IndexPath) {
        if indexPath.section == 1 {
            imageGalleries.append(removedDocuments.remove(at: indexPath.item))
        }
    }
}
