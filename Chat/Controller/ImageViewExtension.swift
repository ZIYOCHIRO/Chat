//
//  ImageViewExtension.swift
//  Chat
//
//  Created by 10.12 on 2019/4/7.
//  Copyright © 2019 Rui. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImageUsingCacheWith(urlString: String) {
        
        // to make the view more dynamic
        self.image = nil
        // check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, responese, error) in
            // download hit an error so lets return out
            
            if error != nil {
                print(error!)
                return
            }
            
            // download the image successfully
            DispatchQueue.main.async {
                if let downloadImage = UIImage(data: data!) {
                    imageCache.setObject(downloadImage, forKey: urlString as AnyObject)
                    self.image = downloadImage
                }
                
            }
        }).resume()
    }


}
