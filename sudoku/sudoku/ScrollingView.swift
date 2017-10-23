//
//  ScrollingView.swift
//  sudoku
//
//  Created by Gautam on 10/22/17.
//  Copyright © 2017 Gautam. All rights reserved.
//

import UIKit

class ScrollingView: UIView {
    
    var mBackground: UIImage = #imageLiteral(resourceName: "numbers")
    var mScrollPos: Int = 0
    
    override func draw(_ rect: CGRect) {
        
        // See how big the view is (ignoring padding)
        _ = rect.width;
        _ = rect.height;
        
        // Draw the background
        // Make the background bigger than it needs to be
        let m = max(mBackground.size.height,
                    mBackground.size.width)
        mBackground = resizeImage(image: mBackground, targetSize: CGSize(width: m, height: m))
        
        // Shift where the image will be drawn
        mScrollPos += 1;
        if (mScrollPos >= Int(m)) {
            mScrollPos -= Int(m);
        }
        rect.applying(CGAffineTransform.init(translationX: -(CGFloat)(mScrollPos), y: -(CGFloat)(mScrollPos)))
        
        // Draw it and indicate it should be drawn next time too
        mBackground.draw(in: rect)
        setNeedsDisplay()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio,height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
}
