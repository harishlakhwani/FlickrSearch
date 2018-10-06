//
//  FlickrImageView.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import UIKit

class FlickrImageView: UIImageView {
    
    var defaultImage : UIImage?
    
    public var imageURL : URL? {
        didSet {
            self.image = defaultImage
            if let urlString = imageURL?.absoluteString {
                CachingHandler.sharedCachingHandler.fetchImageFrom(urlString: urlString) { [weak self] image, url in
                    guard let strongSelf = self else { return }
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        if strongSelf.imageURL?.absoluteString == url {
                            strongSelf.image = image ?? strongSelf.defaultImage
                        }
                    })
                }
            }
        }
    }
    
    func setImageURLString(_ urlString: String, withDefaultImage: UIImage?) {
        defaultImage = withDefaultImage
        imageURL = URL(string: urlString)
    }
}


class CachingHandler {
    
    let imageCache = NSCache<NSString, AnyObject>()
    
    class var sharedCachingHandler : CachingHandler {
        struct Static {
            static let instance : CachingHandler = CachingHandler()
        }
        return Static.instance
    }
    
    func fetchImageFrom(urlString: String, completionHandler: @escaping (_ image: UIImage?, _ url: String) -> ()) {
        
        DispatchQueue.global(qos: .background).async {
            
            let data: NSData? = self.imageCache.object(forKey: urlString as NSString) as? NSData
            
            if let unwrappedData = data {
                let image = UIImage(data: unwrappedData as Data)
                DispatchQueue.main.async {
                    completionHandler(image, urlString)
                }
                return
            }
            
            let urlSession = URLSession.shared
            let urlRequest = URLRequest(url: URL(string: urlString)!);
            
            urlSession.dataTask(with: urlRequest) { data, response, error in
                
                if (error != nil) {
                    completionHandler(nil, urlString)
                    return
                }
                
                if let unwrappedData = data{
                    let image = UIImage(data: unwrappedData)
                    self.imageCache.setObject(unwrappedData as AnyObject, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        completionHandler(image, urlString)
                    }
                }
                }.resume()
            
        }
    }
}
