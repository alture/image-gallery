//
//  ImageGalleryCollectionViewCell.swift
//  Image Gallery
//
//  Created by Redemax on 4/16/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView! {
        didSet {
            spinner?.stopAnimating()
        }
    }
    @IBOutlet private weak var selectionImage: UIImageView!
    
    var isEditing: Bool = false {
        didSet {
            selectionImage.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                selectionImage.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
            }
        }
    }
    
    var urlOfImage: URL? {
        didSet {
            imageView.image = nil
            spinner.startAnimating()
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = urlOfImage {
            imageView.loadImage(fromURL: url)
        }
    }
}

