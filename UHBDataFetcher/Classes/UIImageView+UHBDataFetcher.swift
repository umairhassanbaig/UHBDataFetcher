//
//  UIImageView+UHBDataFetcher.swift
//  DataCacheSample
//
//  Created by Umair Hassan Baig on 7/8/17.
//  Copyright © 2017 Umair Hassan Baig. All rights reserved.
//

import UIKit



// MARK: - Category on imageview that provides block based callback for completion and it respects the sequence of call made by images and sets the latest called image and clears all previous requests for the imageview
extension UIImageView : UHBDataFetcherDelegate {
    
    
    //=================================
    // MARK: - Public interface
    //=================================
    
    /// Set images for url and gives back result in callback
    ///
    /// - Parameters:
    ///   - forURL: uri for the image
    ///   - completion: Callback on completion. UIImage or NSError for success or failure respectively
    public func uhb_setImage(forURL: String, completion : ((UIImage?, NSError?) -> Void)?) {
        //Cancelling previous requests
        UHBDataFetcher.shared.cancelAll(forDelegate: self);
        self.image = nil;
        
        //Setting associated callback that will be executed when the delegate is called, to get the image and set
        self.callback = {
            [weak self](image, error) in
            //Setting the image and executing completion if given by user
            self?.image = image;
            if self?.callback != nil {
                completion?(image, error);
            }
        }
        
        UHBDataFetcher.shared.data(forURL: forURL, delegate: self);
        
    }
    
    
    /// Sets image for url
    ///
    /// - Parameter forURL: url for which the image has to be set.
    public func uhb_setImage(forURL: String) {
        self.uhb_setImage(forURL: forURL, completion: nil);
    }
    
    
    //=================================
    // MARK: - DataFetcher delegate
    //=================================
    public func loadingCompleted(url: String, error: NSError?, data: Data?, cached_data : Bool) {
        
        if data != nil{
            if let image = UIImage(data: data!) {
                self.image = image;
            }
        }
        self.callback?(image, error);
    }
    
    
    //=================================
    // MARK: - Object Association
    //=================================
    /// Objc Association to store a closure
    private var callback: ((UIImage?, NSError?) -> Void)? {
        get {
            return (objc_getAssociatedObject(self, &xoAssociationKey) as? ((UIImage?, NSError?) -> Void))!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
}

/// Association key for block
private var xoAssociationKey: UInt8 = 0

