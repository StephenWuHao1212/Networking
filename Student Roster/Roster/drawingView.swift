//
//  DrawingView.swift
//  Roster
//
//  Created by Guoshan Liu on 9/21/15.
//  Copyright (c) 2015 Guoshan Liu. All rights reserved.
//

import UIKit

class drawingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if rect.size.height == 100 {
            //The Gradient
            let context = UIGraphicsGetCurrentContext()
            let locations: [CGFloat] = [ 0.0, 0.25, 0.5, 0.75 ]
            let colors = [UIColor.redColor().CGColor,
                UIColor.yellowColor().CGColor,
                UIColor.blueColor().CGColor,
                UIColor.purpleColor().CGColor]
            
            let colorspace = CGColorSpaceCreateDeviceRGB()
            
            let gradient = CGGradientCreateWithColors(colorspace, colors, locations)
            
            var startPoint = CGPoint()
            var endPoint =  CGPoint()
            
            startPoint.x = 0.0
            startPoint.y = 0.0
            endPoint.x = 100
            endPoint.y = 100
            
            CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0)
        } else {
            print("haha")
            let con = UIGraphicsGetCurrentContext()
            CGContextAddEllipseInRect(con, CGRectMake(0, 0, 20, 70))
            CGContextSetFillColorWithColor(con, UIColor.cyanColor().CGColor)
            CGContextFillPath(con)
            for _ in 0..<5 {
                CGContextTranslateCTM(con, 20, 100)
                CGContextRotateCTM(con, 30*CGFloat(M_PI)/180.0)
                CGContextTranslateCTM(con, -20, -100)
                
                CGContextAddEllipseInRect(con, CGRectMake(0, 0, 20, 70))
                CGContextSetFillColorWithColor(con, UIColor.cyanColor().CGColor)
                CGContextFillPath(con)
            }
            
            /* let con1 = UIGraphicsGetCurrentContext()
            CGContextAddEllipseInRect(con1, CGRectMake(0, 0, 20, 70))
            CGContextSetFillColorWithColor(con1, UIColor.blueColor().CGColor)
            CGContextFillPath(con1)*/
        }
        
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
