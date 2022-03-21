//
//  MarioPlayerCacheManager.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation
public extension Notification.Name {
    static var MarioPlayerCacheManagerDidUpdateCache = Notification.Name.init("com.Mario.Customplayer.CacheManagerDidUpdateCache")
    static var MarioPlayerCacheManagerDidFinishCache = Notification.Name.init("com.Mario.Customplayer.CacheManagerDidFinishCache")
    static var MarioPlayerCacheManagerDidCleanCache = Notification.Name.init("com.Mario.Customplayer.CacheManagerDidCleanCache")
}

open class MarioPlayerCacheManager: NSObject{
    
    static public let MarioPlayerCacheConfigurationKey: String = "CustomPlayerCacheConfigurationKey"
    static public let MarioPlayerCacheErrorKey: String = "CustomPlayerCacheErrorKey"
    static public let MarioPlayerCleanCacheKey: String = "CustomPlayerCleanCacheKey"
    
    public static var mediaCacheNotifyInterval = 0.1
    
    fileprivate let ioQueue = DispatchQueue(label: "com.customplayer.ioQueue")
    fileprivate var fileManager: FileManager!
    
    public static let shared = MarioPlayerCacheManager()
    open private(set) var cacheConfig = MarioPlayerCacheConfiguration()
    
    public override init() {
        super.init()
        ioQueue.async {
            self.fileManager = FileManager()
        }
    }
    static public func cacheDirectory() -> String {
        return NSTemporaryDirectory().appending("customplayerCache")
    }
    static public func cacheFilePath(for url: URL) -> String {
        if let cacheFolder = url.lastPathComponent.components(separatedBy: ".").first {
            let cacheFilePath = (cacheDirectory().appending("/\(cacheFolder)") as NSString).appendingPathComponent(url.lastPathComponent)
            print(cacheFilePath)
            return cacheFilePath
        }
        
        return (cacheDirectory() as NSString).appendingPathComponent(url.lastPathComponent)
    }
    static public func cacheConfiguration(forURL url: URL) -> MarioPlayerCacheMediaConfiguration {
        let filePath = cacheFilePath(for: url)
        let configuration = MarioPlayerCacheMediaConfiguration.configuration(filePath: filePath)
        return configuration
    }
    open func calculateCacheSize(completion handler: @escaping ((_ size: UInt) -> ())) {
        ioQueue.async {
            let cacheDirectory = MarioPlayerCacheManager.cacheDirectory()
            let (_, diskCacheSize, _) = self.cachedFiles(atPath: cacheDirectory, onlyForCacheSize: true)
            DispatchQueue.main.async {
                handler(diskCacheSize)
            }
        }
    }
    open func cleanAllCache() {
        ioQueue.sync {
            do {
                let cacheDirectory = MarioPlayerCacheManager.cacheDirectory()
                try fileManager.removeItem(atPath: cacheDirectory)
            } catch { }
        }
    }
    open func cleanOldFiles(completion handler: (()->())? = nil) {
        ioQueue.sync {
            let cacheDirectory = MarioPlayerCacheManager.cacheDirectory()
            var (URLsToDelete, diskCacheSize, cachedFiles) = self.cachedFiles(atPath: cacheDirectory, onlyForCacheSize: false)
            
            for fileURL in URLsToDelete {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch _ { }
            }
            
            if cacheConfig.maxCacheSize > 0 && diskCacheSize > cacheConfig.maxCacheSize {
                let targetSize = cacheConfig.maxCacheSize / 2
                
                let sortedFiles = cachedFiles.keysSortedByValue {
                    resourceValue1, resourceValue2 -> Bool in
                    
                    if let date1 = resourceValue1.contentAccessDate,
                        let date2 = resourceValue2.contentAccessDate
                    {
                        return date1.compare(date2) == .orderedAscending
                    }
                    
                    return true
                }
                
                for fileURL in sortedFiles {
                    let (_, cacheSize, _) = self.cachedFiles(atPath: fileURL.path, onlyForCacheSize: true)
                    diskCacheSize -= cacheSize
                    
                    do {
                        try fileManager.removeItem(at: fileURL)
                    } catch { }
                    
                    URLsToDelete.append(fileURL)
                    
                    if diskCacheSize < targetSize {
                        break
                    }
                }
            }
            
            DispatchQueue.main.async {
                
                if URLsToDelete.count != 0 {
                    let cleanedHashes = URLsToDelete.map { $0.lastPathComponent }
                    NotificationCenter.default.post(name: .MarioPlayerCacheManagerDidCleanCache, object: self, userInfo: [MarioPlayerCacheManager.MarioPlayerCleanCacheKey: cleanedHashes])
                }
                
                handler?()
            }
        }
    }
    fileprivate func cachedFiles(atPath path: String, onlyForCacheSize: Bool) -> (urlsToDelete: [URL], diskCacheSize: UInt, cachedFiles: [URL: URLResourceValues]) {
        
        let expiredDate: Date? = (cacheConfig.maxCacheAge < 0) ? nil : Date(timeIntervalSinceNow: -cacheConfig.maxCacheAge)
        
        var cachedFiles = [URL: URLResourceValues]()
        var urlsToDelete = [URL]()
        var diskCacheSize: UInt = 0
        let resourceKeys: Set<URLResourceKey> = [.isDirectoryKey, .contentAccessDateKey, .totalFileAllocatedSizeKey]
        let fullPath = (path as NSString).expandingTildeInPath
        do {
            let url = URL(fileURLWithPath: fullPath)
            
            if let directoryEnumerator = fileManager.enumerator(at:url, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles], errorHandler: nil) {
                for (_ , value) in directoryEnumerator.enumerated() {
                    do {
                        if let fileURL = value as? URL{
                            let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                            
                            if !onlyForCacheSize,
                                let expiredDate = expiredDate,
                                let lastAccessData = resourceValues.contentAccessDate,
                                (lastAccessData as NSDate).laterDate(expiredDate) == expiredDate
                            {
                                urlsToDelete.append(fileURL)
                                continue
                            }
                            
                            
                            if !onlyForCacheSize && resourceValues.isDirectory == true {
                                cachedFiles[fileURL] = resourceValues
                            }
                            
                            if let size = resourceValues.totalFileAllocatedSize {
                                diskCacheSize += UInt(size)
                            }
                        }
                    } catch { }
                }
            }
        }
        return (urlsToDelete, diskCacheSize, cachedFiles)
        
    }
}
extension Dictionary {
    func keysSortedByValue(_ isOrderedBefore: (Value, Value) -> Bool) -> [Key] {
        return Array(self).sorted{ isOrderedBefore($0.1, $1.1) }.map{ $0.0 }
    }
}

