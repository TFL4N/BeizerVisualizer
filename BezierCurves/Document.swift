//
//  Document.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa

class Document: NSDocument {

    var bezier_curve: CubicBezierCurve = CubicBezierCurve()
    var settings: Settings = Settings()
    
    weak var settings_window_controller: NSWindowController! = nil
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
    }
    
    func showSettingsViewController() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        
        // create new settings window
        if self.settings_window_controller == nil {
            self.settings_window_controller = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Settings Window Contoller")) as! NSWindowController
            self.settings_window_controller.shouldCloseDocument = false
            
            self.addWindowController(self.settings_window_controller)
        }
        
        self.settings_window_controller.showWindow(self)
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        let dict: [String:Any] = [
            "bezier_curve" : self.bezier_curve,
            "settings" : self.settings
        ]
        
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.outputFormat = .xml
        
        archiver.encode(dict, forKey: "root")
        archiver.finishEncoding()
        
        return data as Data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String:Any]
        self.bezier_curve = dict["bezier_curve"] as! CubicBezierCurve
        self.settings = dict["settings"] as? Settings ?? settings
    }
}


extension NSViewController {
    var document: Document? {
        return self.view.window?.windowController?.document as? Document
    }
}
