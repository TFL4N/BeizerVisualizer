//
//  Settings.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa

class Settings: NSObject, NSCoding {
    @objc dynamic var origin_offset: Point = Point(x: 0.0, y: 0.0)
    @objc dynamic var display_bounds: Point = Point(x: 10.0, y: 10.0)
    
    @objc dynamic var major_interval: Double = 1.0
    @objc dynamic var major_line_width: Double = 1.0
    @objc dynamic var major_line_color: NSColor = NSColor(white: 0.9, alpha: 1.0)
    
    @objc dynamic var axis_line_width: Double = 1.0
    @objc dynamic var axis_line_color: NSColor = NSColor.black
    
    @objc dynamic var curve_line_width: Double = 1.0
    @objc dynamic var curve_line_color: NSColor = NSColor.black
    
    override init() {
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.origin_offset = aDecoder.decodeObject(forKey: "settings_origin_offset") as? Point ?? Point(x: 0.0, y: 0.0)
        self.display_bounds = aDecoder.decodeObject(forKey: "settings_display_bounds") as? Point ?? Point(x: 10.0, y: 10.0)
        
        /// major lines
        self.major_interval = aDecoder.decodeDouble(forKey: "settings_major_interval")
        if self.major_interval == 0.0 {
            self.major_interval = 5.0
        }
        
        self.major_line_width = aDecoder.decodeDouble(forKey: "settings_major_line_width")
        if self.major_line_width == 0.0 {
            self.major_line_width = 1.0
        }
        
        self.major_line_color = aDecoder.decodeObject(forKey: "settings_major_line_color") as? NSColor ?? NSColor(white: 0.9, alpha: 1.0)
        
        /// axis
        self.axis_line_width = aDecoder.decodeDouble(forKey: "settings_axis_line_width")
        if self.axis_line_width == 0.0 {
            self.axis_line_width = 1.0
        }
        
        self.axis_line_color = aDecoder.decodeObject(forKey: "settings_axis_line_color") as? NSColor ?? NSColor.black
        
        /// curve
        self.curve_line_width = aDecoder.decodeDouble(forKey: "settings_curve_line_width")
        if self.curve_line_width == 0.0 {
           self.curve_line_width = 1.0
        }
        
        self.curve_line_color = aDecoder.decodeObject(forKey: "settings_curve_line_color") as? NSColor ?? NSColor.black
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.origin_offset, forKey: "settings_origin_offset")
        aCoder.encode(self.display_bounds, forKey: "settings_display_bounds")
        
        aCoder.encode(self.major_interval, forKey: "settings_major_interval")
        aCoder.encode(self.major_line_width, forKey: "settings_major_line_width")
        aCoder.encode(self.major_line_color, forKey: "settings_major_line_color")
        
        aCoder.encode(self.axis_line_width, forKey: "settings_axis_line_width")
        aCoder.encode(self.axis_line_color, forKey: "settings_axis_line_color")
        
        aCoder.encode(self.curve_line_width, forKey: "settings_curve_line_width")
        aCoder.encode(self.curve_line_color, forKey: "settings_curve_line_color")
    }
    
    func registerObserver(_ object: NSObject) {
        self.origin_offset.registerObserver(object)
        self.display_bounds.registerObserver(object)
        
        self.addObserver(object, forKeyPath: "major_interval", options: .new, context: nil)
        self.addObserver(object, forKeyPath: "major_line_width", options: .new, context: nil)
        self.addObserver(object, forKeyPath: "major_line_color", options: .new, context: nil)
        
        self.addObserver(object, forKeyPath: "axis_line_width", options: .new, context: nil)
        self.addObserver(object, forKeyPath: "axis_line_color", options: .new, context: nil)
        
        self.addObserver(object, forKeyPath: "curve_line_width", options: .new, context: nil)
        self.addObserver(object, forKeyPath: "curve_line_color", options: .new, context: nil)
    }
    
    func unregisterObserver(_ object: NSObject) {
        self.origin_offset.unregisterObserver(object)
        self.display_bounds.unregisterObserver(object)
        
        self.removeObserver(object, forKeyPath: "major_interval")
        self.removeObserver(object, forKeyPath: "major_line_width")
        self.removeObserver(object, forKeyPath: "major_line_color")
        
        self.removeObserver(object, forKeyPath: "axis_line_width")
        self.removeObserver(object, forKeyPath: "axis_line_color")
        
        self.removeObserver(object, forKeyPath: "curve_line_width")
        self.removeObserver(object, forKeyPath: "curve_line_color")
    }
}
