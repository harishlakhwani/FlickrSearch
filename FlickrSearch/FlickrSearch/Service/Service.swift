//
//  Service.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import Foundation

class Service
{
    class func request(urlString: String,
                       completionHandler: @escaping (_ success: Bool, Data?, Error?) -> ()) {
        
        let urlString = urlString
        guard let url = URL(string: urlString) else { return }
        debugPrint("URL \(urlString)")
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data
            else {
                completionHandler(false, nil, error)
                return
            }
            completionHandler(true, data, nil)
        }.resume()
    }
}
