//
//  UHBDataFetcher.swift
//  DataCacheSample
//
//  Created by Umair Hassan Baig on 7/6/17.
//  Copyright © 2017 Umair Hassan Baig. All rights reserved.
//

import UIKit


@objc public protocol UHBDataFetcherDelegate : class {
    
    func loadingCompleted(url: String, error: NSError?, data: Data?, cached_data : Bool);
    @objc optional func loadingCancelled(url: String)
    @objc optional func cacheCleared(url: String)
}


public class UHBDataFetcher: NSObject {

    /// Shared instance can be used all over the app with shared cache
    public static let shared = UHBDataFetcher();
    
    
    /// New instances can be created. But that will create a separate cache and separate. Using a single instance all over the app is recommended.
    public override init() {
        self.data_queue = OperationQueue();
        self.cache = UHBDataCache(capacity: 300);
        super.init()
    }
    
    public convenience init(cache_capacity : Int) {
        self.init();
        self.cache_capacity = cache_capacity;
    }
    
    /// Capacity of cache
    public var cache_capacity : Int {
        get {
            return self.cache.capacity;
        }
        set {
            self.cache.capacity = newValue;
        }
    }
    
    //Private
    private var data_queue : OperationQueue
    private var cache : UHBDataCache//NSCache<AnyObject, AnyObject>
    
    
    
    
    
    //=================================
    // MARK: - Public interface
    //=================================
    
    
    /// Starts fetching data from specified url for the passed delegate object.
    ///
    /// - Parameters:
    ///   - forURL: URL for which data has to be fetched
    ///   - delegate: Delegate object to be notified
    public func data(forURL: String, delegate: UHBDataFetcherDelegate) {
        
        //Checking if already present in cache
        if let cached = self.cache.object(forKey: forURL) as? Data
        {
            delegate.loadingCompleted(url: forURL, error: nil, data: cached, cached_data: true);
        
        } else {
            //Check if operation with url already exists
            var operation = self.data_queue.operations.first(where: {forURL == ($0 as! DownloadOperation).request_url }) as? DownloadOperation
        
            if operation == nil {
                operation = DownloadOperation(request_url: forURL);
                self.data_queue.addOperation(operation!);
            }
            //Adding delegate as an observer. See implementation of addObserver
            operation!.addObserver(observer: delegate);
            
            operation!.onFetchCompletion = {
                (observers, error, data) in
                if error == nil && data != nil {
                    self.cache.setObject(data as AnyObject, forKey: forURL)
                }
                DispatchQueue.main.async {
                    //Notifying all observers for the downloaded operation
                    observers.forEach({$0.loadingCompleted(url: forURL, error: error, data: data, cached_data: false)});
                }
            }
        }
    }

    
    

    
    /// Cancels download of a specified url for specified delegate
    ///
    /// - Parameters:
    ///   - forURL: URL of which download has to be cancelled
    ///   - delegate: Object for which the url download has to be cancelled
    public func cancel(forURL: String, delegate : UHBDataFetcherDelegate) {
        
        if let operation = self.data_queue.operations.first(where: {forURL == ($0 as! DownloadOperation).request_url }) as? DownloadOperation {
            operation.removeObserver(observer: delegate);
        }
        delegate.loadingCancelled?(url: forURL)
    }
    
    
    
    
    
    /// Cancels all downloads only for specified delegate. Delegate will not be notified for the download
    ///
    /// - Parameter forDelegate: Delegate object for which the download has to be abandoned
    public func cancelAll(forDelegate : UHBDataFetcherDelegate) {
      
        self.data_queue.operations.forEach({
            if let op = $0 as? DownloadOperation {
                op.removeObserver(observer: forDelegate);
            }
        })
    }
    
    
    
    
    /// Clears cached data for the specified url and informs delegate
    ///
    /// - Parameters:
    ///   - forURL: URL for which the cache is
    ///   - delegate: Object to be informed
    
    public func clearCache(forURL: String, delegate : UHBDataFetcherDelegate?) {
        self.cache.removeObject(forKey: forURL);
        delegate?.cacheCleared?(url: forURL)
    }
    

    /// Clears evrything that has been cached
    public func clearCache() {
        self.cache.removeAllObjects();
    }
    
}



//=================================
// MARK: - Download Operation
//=================================

fileprivate class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}


fileprivate extension Array where Element:Weak<UHBDataFetcherDelegate> {
    /// Filters nil values
    mutating func reap () {
        self = self.filter { nil != $0.value }
    }
}



private class DownloadOperation: Operation {

    var onFetchCompletion : ((_ observers : [UHBDataFetcherDelegate],_ error: NSError?, _ data: Data?) -> Void)?
    var request_url : String
    /// Storing observers as weak to avoid retain cycles
    var observers = [Weak<UHBDataFetcherDelegate>]()
    
    
    
    
    init(request_url : String) {
        self.request_url = request_url;
        super.init();
    }
    
    
    /// Adds an observer if does'nt exist already
    ///
    /// - Parameter observer: Observer to be added.
    func addObserver(observer: UHBDataFetcherDelegate) {
        let idx = self.observers.index(where: {$0.value === observer})
        if idx == nil {
            self.observers.append(Weak(value: observer));
        }
    }
    
    
    
    
    
    /// Removes an observer if exists
    ///
    /// - Parameter observer: Observer to be removed
    func removeObserver(observer : UHBDataFetcherDelegate) {
        let idx = self.observers.index(where: {$0.value === observer})
        if idx != nil {
            self.observers.remove(at: idx!);
        }
        self.observers.reap();
        
        //Enable to: If all observers are gone cancel a thread
        /*if self.observers.count == 0 {
            self.cancel();
        }*/
    }
    
    
    
    
    
    /// Operations main method that downloads the data if the url is valid and notifies UHBDataFetcher that notifies all observers
    override func main() {
        
        if self.isCancelled { return }
        if let url = URL(string: self.request_url) {
            var data : Data?
            do {
                data = try Data(contentsOf: url)
            } catch {
                if self.isCancelled { return }
                let error = NSError(domain: "DownloadOperation", code: 123, userInfo: [NSLocalizedDescriptionKey : "Unable to download data"]);
                let obs = self.observers.map({$0.value}) as! [UHBDataFetcherDelegate]
                self.onFetchCompletion?(obs, error, nil);
                return;
            }
            
            if self.isCancelled { return }
            let obs = self.observers.map({$0.value}) as! [UHBDataFetcherDelegate]
            self.onFetchCompletion?(obs, nil, data)
        }
        
    }
}
