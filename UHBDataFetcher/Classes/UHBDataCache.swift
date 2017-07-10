//
//  UHBDataCache.swift
//  DataCacheSample
//
//  Created by Umair Hassan Baig on 7/8/17.
//  Copyright © 2017 Umair Hassan Baig. All rights reserved.
//

import UIKit


/// UHBDataCache is self memory managing cache that caches any kind of objects. It manages objects w.r.t given capacity and clears object w.r.t date Hard cache will be supported soon
class UHBDataCache: NSObject {
    
    /// Maximum capacity of cahce
    public var capacity = 0;
    
    private var cache : [AnyHashable : Any]
    private var clearance_factor : Int = 4;
    public override init() {
        self.capacity = 300
        self.cache = [AnyHashable : Any]();
        super.init();
        NotificationCenter.default.addObserver(self, selector: #selector(recievedMemoryWarning), name: .UIApplicationDidReceiveMemoryWarning, object: nil);
    }
    

    /// Convienience initializer with cahce maximum capicity
    ///
    /// - Parameter capacity: Maximum capacity of cahce.
    convenience init(capacity : Int) {
        self.init();
        self.capacity = capacity
    }
    
    
    /// Set Any Object in cahce with key
    ///
    /// - Parameters:
    ///   - obj: Object to be set in cache
    ///   - key: key for the object to store
    open func setObject(_ obj: Any, forKey key: AnyHashable){
        
        (self.cache as NSObject).sync(closure: {

            self.cache[key] = UHBCacheObject(object: obj);
            if self.cache.count > self.capacity {
               //Clearing 25%(Based on clearance factor) cache of older objects of older use
                var keys = self.cache.sortedKeysByValue(isOrderedBefore: { return (($0 as! UHBCacheObject).date.compare(($1 as! UHBCacheObject).date)) == .orderedAscending})
                for n in 0...Int(self.cache.count/self.clearance_factor) {
                    self.cache.removeValue(forKey: keys[n]);
                }
            }
            
        })
        
    }
    
    /// Returns stored object for the given key
    ///
    /// - Parameter key: Key for the object to be retrieved
    /// - Returns: Object if present else it returns nil
    open func object(forKey key: AnyHashable) -> Any? {
        let cached_obj = (self.cache[key] as? UHBCacheObject);
        cached_obj?.date = Date();
        return cached_obj?.object;
    }
    
    
    /// Clears cache. Removes all objects in the cache
    open func removeAllObjects() {
        self.cache.removeAll();
    }
    
    /// Removes object for the key from cache if present
    ///
    /// - Parameter key: key for the object to be removed
    open func removeObject(forKey key: AnyHashable){
        self.cache.removeValue(forKey: key);
    }
    
    

    /// Clears objects if app memory is low
    @objc private func recievedMemoryWarning() {
        self.cache.removeAll();
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
    /// Wrapper object with date to manage order by usage
    private class UHBCacheObject : NSObject {
        var date : Date
        var object : Any
        
        init(object : Any) {
            self.date = Date();
            self.object = object;
            super.init();
        }
        
    }
}



// MARK: - Mutex safety
fileprivate extension NSObject {
    
    /// Thread safe block execution on any NSObject that is protected with mutex lock
    ///
    /// - Parameters:
    ///   - closure: Execution block to be executed with thread lock
    fileprivate func sync(closure: () -> Void) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
}


// MARK: - Sort helpers
fileprivate extension Dictionary {
    func sortedKeys(isOrderedBefore:(Key,Key) -> Bool) -> [Key] {
        return Array(self.keys).sorted(by: isOrderedBefore)
    }
    
    func sortedKeysByValue(isOrderedBefore:(Value, Value) -> Bool) -> [Key] {
        return sortedKeys {
            isOrderedBefore(self[$0]!, self[$1]!)
        }
    }
}
