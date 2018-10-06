//
//  CollectionViewSource.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import Foundation
import UIKit

let kCellIdentifier = "FlickrPhotoCollectionViewCell"
let cellWidth = ScreenSize.width / 3.0


protocol CollectionViewSourceDelegate: class {
    
    func loadMore()
}
class CollectionViewSource: NSObject {
    
    private var dataArray: [PhotoViewModel] = []
    weak var delegate: CollectionViewSourceDelegate?
}

extension CollectionViewSource {
    
    func updateDataArray(_ array: [PhotoViewModel]?, pageNo: Int) {
        
        guard let unwrappedArray = array else { return }
        
        if pageNo > 1 {
            
            dataArray += unwrappedArray
        } else {
            
            dataArray = unwrappedArray
        }
    }
    
    func getPhotoObjectAtIndexPath(_ indexPath: IndexPath) -> PhotoViewModel? {
        
        if dataArray.count > indexPath.row {
            
            return dataArray[indexPath.row]
        }
        return nil
    }
}

extension CollectionViewSource: UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count;
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCellIdentifier,
                                                            for: indexPath as IndexPath) as? FlickrPhotoCollectionViewCell
            else {
                return UICollectionViewCell()
        }
        let photoViewModel = getPhotoObjectAtIndexPath(indexPath)
        setUpData(cell, photo: photoViewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}

extension CollectionViewSource {
    
    func setUpData(_ cell: FlickrPhotoCollectionViewCell, photo: PhotoViewModel?) {
        
        guard let unwrappedPhoto = photo else { return }
        cell.imageView?.setImageURLString(unwrappedPhoto.imageURLString, withDefaultImage: UIImage(named: "defaultImage"))
    }
}

extension CollectionViewSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if currentOffset >= maximumOffset {
            
            delegate?.loadMore()
        }
    }
}
