//
//  UIImageView+Cache.swift
//  ImageGallery
//
//  Created by Redemax on 5/10/19.
//  Copyright © 2019 Alisher Altore. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func loadImage(fromURL url: URL) {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.image = UIImage(named: "error")
                            return
                        }
                    } else {
                        if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                            let cachedData = CachedURLResponse(response: response, data: data)
                            cache.storeCachedResponse(cachedData, for: request)
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                    }
                }).resume()
            }
        }
    }
}
