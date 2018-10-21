//
//  ViewController.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var display_view: DisplayView!
    
    @IBOutlet var output_textview: NSTextView!
    
    @IBOutlet var P0_X_TextField: NSTextField!
    @IBOutlet var P0_Y_TextField: NSTextField!
    
    @IBOutlet var P1_X_TextField: NSTextField!
    @IBOutlet var P1_Y_TextField: NSTextField!
    
    @IBOutlet var P2_X_TextField: NSTextField!
    @IBOutlet var P2_Y_TextField: NSTextField!
    
    @IBOutlet var P3_X_TextField: NSTextField!
    @IBOutlet var P3_Y_TextField: NSTextField!
    
    private func enumerateTextFields(_ f: (NSTextField)->()) {
        for t in [self.P0_X_TextField,self.P0_Y_TextField,self.P1_X_TextField,self.P1_Y_TextField,self.P2_X_TextField,self.P2_Y_TextField,self.P3_X_TextField,self.P3_Y_TextField] {
            f(t!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.enumerateTextFields { (tf) in
            tf.formatter = NumberFormatter.buildFloatFormatter(min: nil, max: nil)
        }
    }

    private var needsBindings = true
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.display_view.document = self.document
        
        if self.needsBindings {
            self.needsBindings = false
            
            let curve = self.document!.bezier_curve
            
            // P0
            self.P0_X_TextField.bind(.value,
                                     to: curve.p0,
                                     withKeyPath: "x",
                                     options: nil)
            
            self.P0_Y_TextField.bind(.value,
                                     to: curve.p0,
                                     withKeyPath: "y",
                                     options: nil)
            
            // P1
            self.P1_X_TextField.bind(.value,
                                     to: curve.p1,
                                     withKeyPath: "x",
                                     options: nil)
            
            self.P1_Y_TextField.bind(.value,
                                     to: curve.p1,
                                     withKeyPath: "y",
                                     options: nil)
            
            // P2
            self.P2_X_TextField.bind(.value,
                                     to: curve.p2,
                                     withKeyPath: "x",
                                     options: nil)
            
            self.P2_Y_TextField.bind(.value,
                                     to: curve.p2,
                                     withKeyPath: "y",
                                     options: nil)
            
            // P3
            self.P3_X_TextField.bind(.value,
                                     to: curve.p3,
                                     withKeyPath: "x",
                                     options: nil)
            
            self.P3_Y_TextField.bind(.value,
                                     to: curve.p3,
                                     withKeyPath: "y",
                                     options: nil)
        }
    }

    @IBAction func handleShowSettingsPress(_ sender: Any?) {
        self.document?.showSettingsViewController()
    }

    @IBAction func handleSquareGridPress(_ sender: Any?) {
        self.document!.settings.display_bounds.x = (self.document!.settings.display_bounds.y * Double(self.display_view.bounds.width)) / Double(self.display_view.bounds.height)
    }
    
    @IBAction func handleToggleMainControlPoints(_ sender: Any?) {
        self.display_view.toggleMainControlPoints()
    }
}

extension NumberFormatter {
    static func buildFloatFormatter(min: Float?, max: Float?) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.alwaysShowsDecimalSeparator = true
        formatter.isLenient = true
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 5
        formatter.numberStyle = .decimal
        formatter.maximum = max != nil ? NSNumber(value: max!) : nil
        formatter.minimum = min != nil ? NSNumber(value: min!) : nil
        
        return formatter
    }
}
