//
//  FlickrSearchVC.swift
//  FlickrSearch
//
//  Created by Harish Lakhwani on 06/10/18.
//  Copyright © 2018 Harish Lakhwani. All rights reserved.
//

import UIKit

class FlickrSearchVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var searchBar: UISearchBar?
    var dataSource: CollectionViewSource?
    var apiRepository = FlickrSearchAPIRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FlickrSearchVC {
    
    fileprivate func setUpDataSource() {
        
        dataSource = CollectionViewSource()
        dataSource?.delegate = self
        collectionView?.dataSource = dataSource
        collectionView?.delegate = dataSource
    }
    
    fileprivate func fetchPhotos(_ searchString: String?) {
        
        apiRepository.searchString = searchString
        apiRepository.getPhotos { [weak self] (success, photosArray, error) in
            
            guard let strongSelf = self else { return }
            if success {
                
                strongSelf.dataSource?.updateDataArray(photosArray,
                                                       pageNo: strongSelf.apiRepository.pageNo)
                DispatchQueue.main.async {
                    
                    strongSelf.collectionView?.reloadData()
                }
            }
        }
    }
}

extension FlickrSearchVC: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        apiRepository = FlickrSearchAPIRepository()
        view.endEditing(true)
        guard let searchText = searchBar.text, searchText.count > 0
        else { return }
        fetchPhotos(searchText)
    }
}

extension FlickrSearchVC: CollectionViewSourceDelegate {
    
    func loadMore() {
        
        fetchPhotos(apiRepository.searchString)
    }
}

