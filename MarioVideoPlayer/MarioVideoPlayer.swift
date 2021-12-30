//
//  MarioVideoPlayerLayer.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 10/27/21.
//

import UIKit
import AVFoundation
public class MarioVideoPlayer: AVPlayerLayer{
    
    open var slider: MarioProgressBar!
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        /// Remove all observer
    }
}

//MARK: - Public Method
extension MarioVideoPlayer{
    
}
