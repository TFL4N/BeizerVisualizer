//
//  SettingsViewController.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet var origin_offset_x_textfield: NSTextField!
    @IBOutlet var origin_offset_y_textfield: NSTextField!
    
    @IBOutlet var bounds_x_textfield: NSTextField!
    @IBOutlet var bounds_y_textfield: NSTextField!
    
    @IBOutlet var major_interval_textfield: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.origin_offset_x_textfield.formatter = NumberFormatter.buildFloatFormatter(min: nil, max: nil)
        self.origin_offset_y_textfield.formatter = NumberFormatter.buildFloatFormatter(min: nil, max: nil)
        
        self.bounds_x_textfield.formatter = NumberFormatter.buildFloatFormatter(min: nil, max: nil)
        self.bounds_y_textfield.formatter = NumberFormatter.buildFloatFormatter(min: nil, max: nil)
    }
    
    private var needsBindings = true
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if self.needsBindings {
            self.needsBindings = false
            
            let settings = self.document!.settings
            
            self.origin_offset_x_textfield.bind(.value,
                                                to: settings.origin_offset,
                                                withKeyPath: "x",
                                                options: nil)
            self.origin_offset_y_textfield.bind(.value,
                                                to: settings.origin_offset,
                                                withKeyPath: "y",
                                                options: nil)
            
            self.bounds_x_textfield.bind(.value,
                                         to: settings.display_bounds,
                                         withKeyPath: "x",
                                         options: nil)
            self.bounds_y_textfield.bind(.value,
                                         to: settings.display_bounds,
                                         withKeyPath: "y",
                                         options: nil)
        }
    }
    
    @IBAction func handleSquareGridPress(_ sender: Any?) {
        self.document!.main_view_controller.display_view.squareGrid()
    }
}
