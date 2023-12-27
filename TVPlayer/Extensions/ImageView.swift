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
        let urlString = url.absoluteString
        
        if let image = imageCache.object(forKey: urlString as AnyObject) {
            self.image = image as? UIImage
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let image = UIImage(data: data!) else { return }
            imageCache.setObject(image, forKey: urlString as AnyObject)
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
