//
//  MarioPlayerCacheAction.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 12/30/21.
//

import Foundation

public enum MarioPlayerCacheActionType: Int {
    case local
    case remote
}

public struct MarioPlayerCacheAction: Hashable, CustomStringConvertible {
    public var type: MarioPlayerCacheActionType
    public var range: NSRange
    
    public var description: String {
        return "type: \(type)  range:\(range)"
    }
    
    public var hashValue: Int {
        return String(format: "%@%@", NSStringFromRange(range), String(describing: type)).hashValue
    }
    
    public static func ==(lhs: MarioPlayerCacheAction, rhs: MarioPlayerCacheAction) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    init(type: MarioPlayerCacheActionType, range: NSRange) {
        self.type = type
        self.range = range
    }
    
}
