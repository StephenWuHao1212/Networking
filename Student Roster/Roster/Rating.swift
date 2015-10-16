//
//  Rating.swift
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit

class Rating: NSObject {
    var data:[String: Int] = ["":-1]
    
    func encodeWithCoder(coder: NSCoder){
        coder.encodeObject(self.data, forKey: "ratingData")
    }
    
    required init(coder: NSCoder){
        self.data = coder.decodeObjectForKey("ratingData") as! [String:Int]
        super.init()
    }
}
