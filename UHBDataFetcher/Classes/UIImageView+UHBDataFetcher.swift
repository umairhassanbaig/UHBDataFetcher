//
//  UIImageView+UHBDataFetcher.swift
//  DataCacheSample
//
//  Created by Umair Hassan Baig on 7/8/17.
//  Copyright © 2017 Umair Hassan Baig. All rights reserved.
//

import UIKit


private var xoAssociationKey: UInt8 = 0
extension UIImageView : UHBDataFetcherDelegate {
    
    private var callback: ((UIImage) -> Void)? {
        get {
            return (objc_getAssociatedObject(self, &xoAssociationKey) as? ((UIImage) -> Void))!
        }
        set(newValue) {
            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    
    func uhb_setImage(forURL: String, completion : ((UIImage) -> Void)?) {
        UHBDataFetcher.shared.cancelAll(forDelegate: self);
        self.image = nil;
        if completion != nil {
            self.callback = completion!;
        } else {
            self.callback = {
                [weak self](image) in
                self?.image = image;
            }
        }
        UHBDataFetcher.shared.data(forURL: forURL, delegate: self);
        
    }
    func uhb_setImage(forURL: String) {
        self.uhb_setImage(forURL: forURL, completion: nil);
    }
    
    func loadingCompleted(url: String, error: NSError?, data: Data?, cached_data : Bool) {
        
        if data != nil{
            if let image = UIImage(data: data!) {
                self.image = image;
                self.callback?(image);
            }
            
        }
        
    }
    
}
