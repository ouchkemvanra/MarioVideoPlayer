//
//  MarioPlayerDownloadActionWorker.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation
public protocol MarioPlayerDownloadActionWorkerDelegate: NSObjectProtocol {
    func downloadActionWorker(_ actionWorker: MarioPlayerDownloadActionWorker, didReceive response: URLResponse)
    func downloadActionWorker(_ actionWorker: MarioPlayerDownloadActionWorker, didReceive data: Data, isLocal: Bool)
    func downloadActionWorker(_ actionWorker: MarioPlayerDownloadActionWorker, didFinishWithError error: Error?)
}
open class MarioPlayerDownloadActionWorker: NSObject{
    open fileprivate(set) var actions = [MarioPlayerCacheAction]()
    open fileprivate(set) var url: URL
    open fileprivate(set) var cacheMediaWorker: MarioPlayerCacheMediaWorker
    
    open fileprivate(set) var session: URLSession?
    open fileprivate(set) var task: URLSessionDataTask?
    open fileprivate(set) var downloadURLSessionManager: MarioPlayerDownloadURLSessionManager?
    open fileprivate(set) var startOffset: Int = 0
    
    open weak var delegate: MarioPlayerDownloadActionWorkerDelegate?
    
    fileprivate var isCancelled: Bool = false
    fileprivate var notifyTime = 0.0
    
    
    public init(actions: [MarioPlayerCacheAction], url: URL, cacheMediaWorker: MarioPlayerCacheMediaWorker) {
        self.actions = actions
        self.cacheMediaWorker = cacheMediaWorker
        self.url = url
        super.init()
        downloadURLSessionManager = MarioPlayerDownloadURLSessionManager(delegate: self)
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: downloadURLSessionManager, delegateQueue: MarioPlayerCacheSession.shared.downloadQueue)
        self.session = session
    }
    
    deinit {
        cancel()
    }
    
    open func start() {
        processActions()
    }
    
    open func cancel() {
        if session != nil {
            session?.invalidateAndCancel()
        }
        isCancelled = true
    }
    
    internal func processActions() {
        if isCancelled {
            return
        }
        let firstAction = actions.first
        if firstAction == nil {
            delegate?.downloadActionWorker(self, didFinishWithError: nil)
            return
        }
        
        self.actions.remove(at: 0)
        if let action = firstAction {
            if action.type == .local { // local
                if let data = cacheMediaWorker.cache(forRange: action.range) {
                    delegate?.downloadActionWorker(self, didReceive: data, isLocal: true)
                    processActions()
                } else {
                    let nsError = NSError(domain: "com.marioplayer.downloadActionWorker", code: -1, userInfo: [NSLocalizedDescriptionKey: "Read cache data failed."])
                    delegate?.downloadActionWorker(self, didFinishWithError: nsError as Error)
                }
                
            } else {    // remote
                let fromOffset = action.range.location
                let endOffset = action.range.location + action.range.length - 1
                var request = URLRequest(url: url)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData 
                let range = String(format: "bytes=%lld-%lld", fromOffset, endOffset)
                request.setValue(range, forHTTPHeaderField: "Range")        // set HTTP Header
                
                startOffset = action.range.location
                task = self.session?.dataTask(with: request)
                task?.resume()                                 // star download
            }
        }
    }
    
    internal func notify(downloadProgressWithFlush isFlush: Bool, isFinished: Bool) {
        let currentTime = CFAbsoluteTimeGetCurrent()  // Returns the current system absolute time.
        let interval = MarioPlayerCacheManager.mediaCacheNotifyInterval
        if notifyTime < currentTime - interval || isFlush {
            if let configuration = cacheMediaWorker.cacheConfiguration?.copy() {
                let configurationKey = MarioPlayerCacheManager.MarioPlayerCacheConfigurationKey
                let userInfo = [configurationKey: configuration]
                NotificationCenter.default.post(name: .MarioPlayerCacheManagerDidUpdateCache, object: self, userInfo: userInfo)
                
                if isFinished && (configuration as! MarioPlayerCacheMediaConfiguration).progress >= 1.0 {
                    notify(downloadFinishedWithError: nil)
                }
            }
            
        }
    }
    
    internal func notify(downloadFinishedWithError error: Error?) {
        if let configuration = cacheMediaWorker.cacheConfiguration?.copy() {
            let configurationKey = MarioPlayerCacheManager.MarioPlayerCacheConfigurationKey
            let finishedErrorKey = MarioPlayerCacheManager.MarioPlayerCacheErrorKey
            var userInfo: [String : Any] = [configurationKey: configuration]
            if let er = error {
                userInfo[finishedErrorKey] = er
            }
            NotificationCenter.default.post(name: .MarioPlayerCacheManagerDidFinishCache, object: self, userInfo: userInfo)
        }
        
    }
}

// MARK: - MarioPlayerDownloadeURLSessionManagerDelegate
extension MarioPlayerDownloadActionWorker: MarioPlayerDownloadeURLSessionManagerDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        cacheMediaWorker.finishWritting()
        cacheMediaWorker.save()
        if error != nil {
            delegate?.downloadActionWorker(self, didFinishWithError: error)
            notify(downloadFinishedWithError: error)
        } else {
            notify(downloadProgressWithFlush: true, isFinished: true)
            processActions()
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if isCancelled {
            return
        }
        
        let range = NSRange(location: startOffset, length: data.count)
        cacheMediaWorker.cache(data, forRange: range) { [weak self] (isCache) in
            guard let strongSelf = self else { return }
            if (!isCache) {
                let nsError = NSError(domain: "com.marioplayer.downloadActionWorker", code: -2, userInfo: [NSLocalizedDescriptionKey: "Write cache data failed."])
                strongSelf.delegate?.downloadActionWorker(strongSelf, didFinishWithError: nsError as Error)
            }
        }
        
        cacheMediaWorker.save()
        startOffset += data.count
        delegate?.downloadActionWorker(self, didReceive: data, isLocal: false)
        notify(downloadProgressWithFlush: false, isFinished: false)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let mimeType = response.mimeType {
            if (mimeType.range(of: "video/") == nil) &&
                (mimeType.range(of: "audio/") == nil &&
                    mimeType.range(of: "application") == nil){
                completionHandler(.cancel)
            } else {
                delegate?.downloadActionWorker(self, didReceive: response)
                cacheMediaWorker.startWritting()
                completionHandler(.allow)
            }
        }
        
    }
}


