//
//  FlickrSearchAPIDataBuilder.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import Foundation

class GenericDataBuilder {
    
    func deserializeObjectFromData<T>(type: T.Type, data: Data?) -> T? where T: Decodable {
        if let unwrappedData = data {
            do {
                let categoryInfoModel = try JSONDecoder().decode(T.self, from: unwrappedData)
                
                return categoryInfoModel
                
            } catch {}
        }
        return nil
    }
}

class FlickrSearchAPIDataBuilder: GenericDataBuilder {
    
    func deserializeFromData(_ data: Data?) -> FlickrPhotos? {
        
        guard let flickrObject = deserializeObjectFromData(type: FlickrPhotos.self, data: data) else {
            return nil
        }
        return flickrObject
    }
}
