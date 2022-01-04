//
//  MarioUtility.swift
//  MarioVideoPlayer
//
//  Created by Ouch Kemvanra on 10/28/21.
//

import UIKit
public class MarioUtility: NSObject{
    static public func bundle() -> Bundle {
        return Bundle(for: MarioUtility.self)
    }
    
    static public func image(_ imageName: String) -> UIImage? {
         let bundle = bundle()
         return UIImage(named: imageName, in: bundle, compatibleWith: nil)
     }
    static func imageSize(image: UIImage, scaledToSize newSize: CGSize) -> UIImage? {
         UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
         image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
         let newImage = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return newImage;
     }
}
