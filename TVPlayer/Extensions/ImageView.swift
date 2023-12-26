//
//  AsyncImage.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func loadImage(from url: URL?) {
        guard let url = url else { return }
        let request = URLRequest(url: url)
        guard let image = imageCache.object(forKey: url.absoluteString as AnyObject) else {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        guard let image = UIImage(data: data!) else { return }
                        let str = url.absoluteString
                        imageCache.setObject(image, forKey: str as AnyObject)
                        self.image = image
                    }
                }.resume()
            })
            
            
            return
        }
        
        self.image = image as? UIImage
    }
}
