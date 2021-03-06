//
//  MarioPlayerCacheSession.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation
open class MarioPlayerCacheSession: NSObject {
    public fileprivate(set) var downloadQueue: OperationQueue
    static let shared = MarioPlayerCacheSession()
    
    public override init() {
        let queue = OperationQueue()
        queue.name = "com.customplayer.downloadSession"
        downloadQueue = queue
    }
}

