//
//  Point.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

class Point: NSObject, NSCoding {
    @objc dynamic var x: Double
    @objc dynamic var y: Double
    
    var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
    
    override init() {
        self.x = 0
        self.y = 0
        
        super.init()
    }
    
    override var description: String {
        return "(x: \(self.x), y: \(self.y))"
    }
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
        
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let x = aDecoder.decodeDouble(forKey: "point_x")
        let y = aDecoder.decodeDouble(forKey: "point_y")
        
        self.init(x: x, y: y)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.x, forKey: "point_x")
        aCoder.encode(self.y, forKey: "point_y")
    }
}


extension CGPoint {
    public static func +=(lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}
