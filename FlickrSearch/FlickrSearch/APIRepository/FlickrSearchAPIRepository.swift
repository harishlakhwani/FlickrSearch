//
//  FlickrSearchAPIRepository.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import Foundation

class FlickrSearchAPIRepository {
    
    private (set) var pageNo = 0
    private var totalPhotos = -1
    private var currentPhotos = 0
    var searchString: String?
    
    private func getPhotoViewModelArray(_ array: [Photo]?) -> [PhotoViewModel]? {
        
        var photoViewModelArray: [PhotoViewModel] = []
        guard let unwrappedArray = array else { return nil }
        
        for photo in unwrappedArray {
            
            let farm = photo.farm ?? -1
            let server = photo.server ?? ""
            let id = photo.id ?? ""
            let secret = photo.secret ?? ""
            let photoViewModel = PhotoViewModel()
            photoViewModel.imageURLString = "https://farm\(farm).static.flickr.com/" +
                                                                             server +
                                                                                "/" +
                                                                                 id +
                                                                                "_" +
                                                                             secret +
                                                                              ".jpg"
            photoViewModelArray.append(photoViewModel)
        }
        return photoViewModelArray
    }
    
    func getPhotos(_ completionHandler: @escaping (Bool, [PhotoViewModel]?, Error?)-> Void)  {
     
        if currentPhotos == totalPhotos {
            
            completionHandler(false, nil, nil)
            return
        }
        guard let unwrappedSearchString = searchString
        else {
            completionHandler(false, nil, nil)
            return
        }
        pageNo += 1
        let searchAPIUrl = getFlickrSearchApiUrl(unwrappedSearchString)
        Service.request(urlString: searchAPIUrl) { [weak self] (success, data, error) in
            
            guard let strongSelf = self else {
                
                completionHandler(false, nil, error)
                return
            }
            if success == true,
               let unwrappedData = data,
               error == nil {
                
                if let flicrPhotos = FlickrSearchAPIDataBuilder().deserializeFromData(unwrappedData),
                   let photos = flicrPhotos.photos {
                    
                    if let total = photos.total {
                        
                        strongSelf.totalPhotos = total
                    }
                    if let perpage = photos.perpage {
                        
                        strongSelf.currentPhotos += perpage
                    }
                    let photoViewModelArray = strongSelf.getPhotoViewModelArray(photos.photo)
                    completionHandler(true, photoViewModelArray, error)
                } else {
                    
                    completionHandler(false, nil, error)
                }
            } else {
                
                completionHandler(false, nil, error)
            }
        }
    }
    
    private func getFlickrSearchApiUrl(_ searchString: String) -> String {
        
        let searchAPIUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=3e7cc266ae2b0e0d78e279ce8e361736&&format=json&nojsoncallback=1&safe_search=1&page=\(pageNo)&text=\(searchString)"
        return searchAPIUrl
    }
}
