//
//  DisplayView.swift
//  BezierCurves
//
//  Created by Spizzace on 10/20/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Cocoa
import BigNumber

class DisplayView: NSView, NSGestureRecognizerDelegate {
    private var axis_layer: CAShapeLayer = CAShapeLayer()
    private var grid_layer: CAShapeLayer = CAShapeLayer()
    private var curve_layer: CAShapeLayer = CAShapeLayer()
    
    private var p0_layer: CAShapeLayer = CAShapeLayer()
    private var p1_layer: CAShapeLayer = CAShapeLayer()
    private var p2_layer: CAShapeLayer = CAShapeLayer()
    private var p3_layer: CAShapeLayer = CAShapeLayer()
    private var p01_line_layer: CAShapeLayer = CAShapeLayer()
    private var p12_line_layer: CAShapeLayer = CAShapeLayer()
    private var p23_line_layer: CAShapeLayer = CAShapeLayer()
    
    private var q0_layer: CAShapeLayer = CAShapeLayer()
    private var q1_layer: CAShapeLayer = CAShapeLayer()
    private var q2_layer: CAShapeLayer = CAShapeLayer()
    private var q01_line_layer: CAShapeLayer = CAShapeLayer()
    private var q12_line_layer: CAShapeLayer = CAShapeLayer()
    
    private var r0_layer: CAShapeLayer = CAShapeLayer()
    private var r1_layer: CAShapeLayer = CAShapeLayer()
    private var r01_line_layer: CAShapeLayer = CAShapeLayer()
    
    private var b_layer: CAShapeLayer = CAShapeLayer()
    
    private var control_point_size: CGFloat = 10.0
    
    private var control_point_pan_gesture: NSPanGestureRecognizer!
    private var pan_gesture: NSPanGestureRecognizer!
    
    private var isEnabled: Bool = true {
        willSet {
            self.control_point_pan_gesture?.isEnabled = newValue
//            self.pan_gesture?.isEnabled = newValue
        }
    }
    
    var document: Document? = nil {
        willSet {
            if let document = self.document {
                document.bezier_curve.unregisterObserver(self)
                document.settings.unregisterObserver(self)
            }
        }
        
        didSet {
            if let document = self.document {
                document.bezier_curve.registerObserver(self)
                document.settings.registerObserver(self)
            }
            
            self.refresh()
        }
    }
    
    var curve: CubicBezierCurve {
        return self.document?.bezier_curve ?? CubicBezierCurve()
    }
    
    var settings: Settings {
        return self.document?.settings ?? Settings()
    }
    
    private var aspect_ratio: CGFloat {
        return self.layer!.bounds.width / self.layer!.bounds.height
    }
    
    private var x_scale: CGFloat {
        return self.layer!.bounds.width / CGFloat(self.settings.display_bounds.x)
    }
    
    private var y_scale: CGFloat {
        return self.layer!.bounds.height / CGFloat(self.settings.display_bounds.y)
    }
    
    // MARK: Initializers
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        let new_layer = CALayer()
        new_layer.layoutManager = CAConstraintLayoutManager()
        new_layer.backgroundColor = CGColor.white

        self.layer = new_layer
        self.wantsLayer = true
        
        self.settings.display_bounds.x *= Double(self.aspect_ratio)
        
        self.refresh()
        self.createControlPoints()
        self.createControlLines()
        
        self.control_point_pan_gesture = NSPanGestureRecognizer(target: self, action: #selector(handleControlPointPanGesture(_:)))
        self.control_point_pan_gesture.delegate = self
        self.addGestureRecognizer(self.control_point_pan_gesture)
        
        self.pan_gesture = NSPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.pan_gesture.delegate = self
        self.addGestureRecognizer(self.pan_gesture)
    }
    
    // MARK: Control Points
    private func createControlPoints() {
        let main_color = CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let q_color = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let r_color = CGColor(red: 1.0, green: 165.0/255.0, blue: 0.0, alpha: 1.0)
        let b_color = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        self.p0_layer = self.createPointLayer(size: self.control_point_size, color: main_color)
        self.p1_layer = self.createPointLayer(size: self.control_point_size, color: main_color)
        self.p2_layer = self.createPointLayer(size: self.control_point_size, color: main_color)
        self.p3_layer = self.createPointLayer(size: self.control_point_size, color: main_color)
        
        self.q0_layer = self.createPointLayer(size: self.control_point_size, color: q_color)
        self.q1_layer = self.createPointLayer(size: self.control_point_size, color: q_color)
        self.q2_layer = self.createPointLayer(size: self.control_point_size, color: q_color)
        
        self.r0_layer = self.createPointLayer(size: self.control_point_size, color: r_color)
        self.r1_layer = self.createPointLayer(size: self.control_point_size, color: r_color)
        
        self.b_layer = self.createPointLayer(size: self.control_point_size, color: b_color)
        
        self.enumerateControlPoints { (cp) in
            cp.isHidden = true
            cp.actions = [
                "position" : NSNull()
            ]
            self.layer!.addSublayer(cp)
        }
        
        self.enumerateMainControlPoints { (cp) in
            cp.isHidden = false
        }
    }
    
    private func createPointLayer(size: CGFloat, color: CGColor) -> CAShapeLayer {
        let circle_bounds = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        let path = CGPath(ellipseIn: circle_bounds, transform: nil)
        
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        layer.path = path
        layer.fillColor = color
        layer.zPosition = 2.0
        
        return layer
    }
    
    private func createLinePath(start: CGPoint, end: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        return path
    }
    
    private func createControlLines() {
        let createLine = { (color: CGColor) -> CAShapeLayer in
            let path = self.createLinePath(start: CGPoint.zero, end: CGPoint.zero)
            
            let layer = CAShapeLayer()
            layer.path = path
            layer.lineWidth = CGFloat(self.settings.curve_line_width)
            layer.strokeColor = color
            layer.zPosition = 1.0
            
            return layer
        }
        
        let p_line_color = CGColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let q_line_color = CGColor(red: 1.0, green: 165.0/255.0, blue: 0.0, alpha: 1.0)
        let r_line_color = CGColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        
        self.p01_line_layer = createLine(p_line_color)
        self.p12_line_layer = createLine(p_line_color)
        self.p23_line_layer = createLine(p_line_color)
        
        self.q01_line_layer = createLine(q_line_color)
        self.q12_line_layer = createLine(q_line_color)
        
        self.r01_line_layer = createLine(r_line_color)
        
        
        self.enumerateControlLines { (line_layer) in
            line_layer.isHidden = true
            line_layer.actions = [
                "position" : NSNull()
            ]
            self.layer!.addSublayer(line_layer)
        }
    }
    
    // MARK: Public functions
    private var isShowingMajorControlPoints = true
    public func toggleMainControlPoints() {
        if self.isShowingMajorControlPoints {
            self.isShowingMajorControlPoints = false
            self.hideMajorControlPoints()
        } else {
            self.isShowingMajorControlPoints = true
            self.showMajorControlPoints()
        }
    }
    
    public func refresh() {
        self.updateGridLayer()
        self.updateAxisLayer()
        self.updateBezierCurve()
    }
    
    public func squareGrid() {
        self.settings.display_bounds.x = (self.settings.display_bounds.y * Double(self.bounds.width)) / Double(self.bounds.height)
    }
    
    // MARK: Animations
    public func showMajorControlPoints() {
        self.enumerateMainControlPoints { (layer) in
            layer.isHidden = false
        }
    }
    
    public func hideMajorControlPoints() {
        self.enumerateMainControlPoints { (layer) in
            layer.isHidden = true
        }
    }
    
    public func showControlLines() {
        self.enumerateOtherControlPoints { (layer) in
            layer.isHidden = false
        }
        self.enumerateControlLines { (layer) in
            layer.isHidden = false
        }
    }
    
    public func hideControlLines() {
        self.enumerateOtherControlPoints { (layer) in
            layer.isHidden = true
        }
        self.enumerateControlLines { (layer) in
            layer.isHidden = true
        }
    }
    
    private var isAnimating = false
    private let animation_duration: Double = 5.0
    private func startAnimation() {
        self.isEnabled = false
        
        self.showMajorControlPoints()
        self.showControlLines()
        
        let curve = BezierCurve<Double>()
        let p0 = self.curve.p0.bigNumberPoint
        let p1 = self.curve.p1.bigNumberPoint
        let p2 = self.curve.p2.bigNumberPoint
        let p3 = self.curve.p3.bigNumberPoint
        let q_functions = curve.getQPointFunctions(p0: p0, p1: p1, p2: p2, p3: p3)
        let r_functions = curve.getRPointFunctions(p0: p0, p1: p1, p2: p2, p3: p3)
        let b_function = curve.getBPointFunction(p0: p0, p1: p1, p2: p2, p3: p3)
        
        
        //// p lines
        let p0_denorm = self.getDenormalizedPoint(p0.cgPoint)
        let p1_denorm = self.getDenormalizedPoint(p1.cgPoint)
        let p2_denorm = self.getDenormalizedPoint(p2.cgPoint)
        let p3_denorm = self.getDenormalizedPoint(p3.cgPoint)
        
        self.p01_line_layer.path = self.createLinePath(start: p0_denorm, end: p1_denorm)
        self.p12_line_layer.path = self.createLinePath(start: p1_denorm, end: p2_denorm)
        self.p23_line_layer.path = self.createLinePath(start: p2_denorm, end: p3_denorm)
        
        //// animate
        let number_steps: Double = 1_000
        let time_per_step = self.animation_duration / number_steps
        let step_size = 1.0 / number_steps
        
        self.isAnimating = true
        var current_t: Double = 0.0
        
        func moveToStep(t: Double) {
            // q
            let q0 = self.getDenormalizedPoint(q_functions.q0(t).cgPoint)
            let q1 = self.getDenormalizedPoint(q_functions.q1(t).cgPoint)
            let q2 = self.getDenormalizedPoint(q_functions.q2(t).cgPoint)
            
            self.q0_layer.position = q0
            self.q1_layer.position = q1
            self.q2_layer.position = q2
            
            self.q01_line_layer.path = self.createLinePath(start: q0, end: q1)
            self.q12_line_layer.path = self.createLinePath(start: q1, end: q2)
            
            // r
            let r0 = self.getDenormalizedPoint(r_functions.r0(t).cgPoint)
            let r1 = self.getDenormalizedPoint(r_functions.r1(t).cgPoint)
            
            self.r0_layer.position = r0
            self.r1_layer.position = r1
            
            self.r01_line_layer.path = self.createLinePath(start: r0, end: r1)
            
            // b
            let b = self.getDenormalizedPoint(b_function(t).cgPoint)
            
            self.b_layer.position = b
            
            /// loop
            if self.isAnimating {
                current_t += step_size
                
                if current_t > 1.0 {
                    current_t = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + time_per_step) {
                    moveToStep(t: current_t)
                }
            }
        }
        
        // begin animation
        moveToStep(t: current_t)
    }
    
    private func stopAnimation() {
        self.isEnabled = true
        self.isAnimating = false
    }
    
    public func toggleAnimation() {
        if self.isAnimating {
            self.stopAnimation()
        } else {
            self.startAnimation()
        }
    }
    
    // MARK: Gestures
    private var selected_control_point: CAShapeLayer?
    private var control_point_translation: NSPoint = NSPoint.zero
    @objc private func handleControlPointPanGesture(_ gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.selected_control_point = self.getSelectedControlPoint(gesture.location(in: self))
            self.control_point_translation = NSPoint.zero
        case .changed:
            if let point = self.selected_control_point {
                let new_translation = gesture.translation(in: self)
                let change =  self.control_point_translation - new_translation
                self.control_point_translation = new_translation
            
                if point == self.p0_layer {
                    let new_position = self.p0_layer.position - change
                    self.document!.bezier_curve.p0.cgPoint = self.getNormalizedPoint(new_position)
                } else if point == self.p1_layer {
                    let new_position = self.p1_layer.position - change
                    self.document!.bezier_curve.p1.cgPoint = self.getNormalizedPoint(new_position)
                } else if point == self.p2_layer {
                    let new_position = self.p2_layer.position - change
                    self.document!.bezier_curve.p2.cgPoint = self.getNormalizedPoint(new_position)
                } else if point == self.p3_layer {
                    let new_position = self.p3_layer.position - change
                    self.document!.bezier_curve.p3.cgPoint = self.getNormalizedPoint(new_position)
                }
            }
        case .ended, .cancelled, .failed:
            self.selected_control_point = nil
        case .possible:
            break
        }
    }
    
    
    private var pan_translation: NSPoint = NSPoint.zero
    @objc private func handlePanGesture(_ gesture: NSPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.pan_translation = CGPoint.zero
        case .changed:
            let new_translation = gesture.translation(in: self)
            var change = self.pan_translation - new_translation
            self.pan_translation = new_translation
            
            change.x /= self.x_scale
            change.y /= self.y_scale
            
            self.settings.origin_offset.cgPoint -= change
        case .ended, .cancelled, .failed, .possible:
            break
        }
    }
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        if gestureRecognizer == self.control_point_pan_gesture {
            return self.getSelectedControlPoint(gestureRecognizer.location(in: self)) != nil
        } else if gestureRecognizer == self.pan_gesture {
            return true
        }
        
        return false
    }
    
    internal func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer == self.pan_gesture {
            return event.modifierFlags.contains(.option)
        }
        
        return true
    }
    
    private func getSelectedControlPoint(_ location: NSPoint) -> CAShapeLayer? {
        guard self.bounds.contains(location) else {
            return nil
        }
        
        
        let transformation = CGAffineTransform(translationX: self.control_point_size, y: self.control_point_size)
        let control_points = [self.p0_layer, self.p1_layer, self.p2_layer, self.p3_layer]
        for point in control_points {
            if point.frame.contains(location) {
                let local = location - point.position
                if point.path!.contains(local, using: .winding, transform: transformation) {
                    return point
                }
                return point
            }
        }
    
        return nil
    }
    
    // MARK: Enumeration
    private func enumerateControlPoints(_ f:(CAShapeLayer)->()) {
        let control_points = [self.p0_layer, self.p1_layer, self.p2_layer, self.p3_layer, self.q0_layer, self.q1_layer, self.q2_layer, self.r0_layer, self.r1_layer, self.b_layer]
        
        for cp in control_points {
            f(cp)
        }
    }
    
    private func enumerateMainControlPoints(_ f:(CAShapeLayer)->()) {
        let control_points = [self.p0_layer, self.p1_layer, self.p2_layer, self.p3_layer]
        
        for cp in control_points {
            f(cp)
        }
    }
    
    private func enumerateOtherControlPoints(_ f:(CAShapeLayer)->()) {
        let control_points = [self.q0_layer, self.q1_layer, self.q2_layer, self.r0_layer, self.r1_layer, self.b_layer]
        
        for cp in control_points {
            f(cp)
        }
    }
    
    private func enumerateControlLines(_ f:(CAShapeLayer)->()) {
        let lines = [self.p01_line_layer, self.p12_line_layer, self.p23_line_layer, self.q01_line_layer, self.q12_line_layer, self.r01_line_layer]
        
        for l in lines {
            f(l)
        }
    }
    
    // MARK: Point conversion
    private func getNormalizedPoint(_ point: CGPoint) -> CGPoint {
        var output = point
        
        /// adjust scale
        output.x /= self.x_scale
        output.y /= self.y_scale
        
        // adjust origin
        output -= self.settings.origin_offset.cgPoint
        
        return output
    }
    
    private func getDenormalizedPoint(_ point: CGPoint) -> CGPoint {
        var output = point
    
        // adjust origin
        output += self.settings.origin_offset.cgPoint
        
        // adjust scale
        output.x *= self.x_scale
        output.y *= self.y_scale
        
        return output
    }
    
    // MARK: Update fuctions
    private func updateMainControlLines() {
        self.p01_line_layer.path = self.createLinePath(start: self.curve.p0.cgPoint, end: self.curve.p1.cgPoint)
        self.p12_line_layer.path = self.createLinePath(start: self.curve.p1.cgPoint, end: self.curve.p2.cgPoint)
        self.p23_line_layer.path = self.createLinePath(start: self.curve.p2.cgPoint, end: self.curve.p3.cgPoint)
    }
    
    private func updateOtherControlLines(withT t: Double) {
        
    }
    
    private func updateBezierCurve() {
        guard let document = self.document else {
            if self.curve_layer.superlayer != nil {
                self.curve_layer.removeFromSuperlayer()
            }
            
            return
        }
        
        let p0 = self.getDenormalizedPoint(document.bezier_curve.p0.cgPoint)
        let p1 = self.getDenormalizedPoint(document.bezier_curve.p1.cgPoint)
        let p2 = self.getDenormalizedPoint(document.bezier_curve.p2.cgPoint)
        let p3 = self.getDenormalizedPoint(document.bezier_curve.p3.cgPoint)
        
        self.p0_layer.position = p0
        self.p1_layer.position = p1
        self.p2_layer.position = p2
        self.p3_layer.position = p3
        
        let curve_path = CGMutablePath()
        curve_path.move(to: p0)
        curve_path.addCurve(to: p3, control1: p1, control2: p2)
        
        //// shape
        let curve_shape = CAShapeLayer()
        curve_shape.path = curve_path
        curve_shape.lineWidth = CGFloat(self.settings.curve_line_width)
        curve_shape.fillColor = CGColor.clear
        curve_shape.strokeColor = self.settings.curve_line_color.cgColor
        
        if self.curve_layer.superlayer != nil {
            self.curve_layer.removeFromSuperlayer()
        }
        self.curve_layer = curve_shape
        
        self.layer!.addSublayer(self.curve_layer)
    }
    
    private func updateAxisLayer() {
        let axis_path = CGMutablePath()
        
        ///// x-axis
        let x_interval = self.layer!.bounds.size.width / CGFloat(self.settings.display_bounds.x)
        let x_origin = CGFloat(self.settings.origin_offset.x) * x_interval
        
        let x_start = CGPoint(x: x_origin, y: 0)
        let x_end = CGPoint(x: x_origin, y: self.layer!.bounds.size.height)
        
        axis_path.move(to: x_start)
        axis_path.addLine(to: x_end)
        
        ///// y-axis
        let y_interval = self.layer!.bounds.size.height / CGFloat(self.settings.display_bounds.y)
        let y_origin = CGFloat(self.settings.origin_offset.y) * y_interval
        
        let y_start = CGPoint(x: 0, y: y_origin)
        let y_end = CGPoint(x: self.layer!.bounds.size.width, y: y_origin)
        
        axis_path.move(to: y_start)
        axis_path.addLine(to: y_end)
        
        //// shape
        let axis_shape = CAShapeLayer()
        axis_shape.path = axis_path
        axis_shape.lineWidth = CGFloat(self.settings.axis_line_width)
        axis_shape.fillColor = CGColor.clear
        axis_shape.strokeColor = self.settings.axis_line_color.cgColor
        
        if self.axis_layer.superlayer != nil {
            self.axis_layer.removeFromSuperlayer()
        }
        self.axis_layer = axis_shape
        
        self.layer!.addSublayer(self.axis_layer)
    }
    
    private func updateGridLayer() {
        let grid_path = CGMutablePath()
        
        ///// x
        let x_interval = self.layer!.bounds.size.width / CGFloat(self.settings.display_bounds.x)
        let x_origin = CGFloat(self.settings.origin_offset.x) * x_interval
        var x_position: CGFloat = x_origin + x_interval
        
        while x_position < self.layer!.bounds.size.width {
            let start = CGPoint(x: x_position, y: 0)
            let end = CGPoint(x: x_position, y: self.layer!.bounds.size.height)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
            x_position += x_interval
        }
        
        x_position = x_origin - x_interval
        while x_position > 0 {
            let start = CGPoint(x: x_position, y: 0)
            let end = CGPoint(x: x_position, y: self.layer!.bounds.size.height)

            grid_path.move(to: start)
            grid_path.addLine(to: end)

            // loop
            x_position -= x_interval
        }
        
        //// y
        let y_interval = self.layer!.bounds.size.height / CGFloat(self.settings.display_bounds.y)
        let y_origin = CGFloat(self.settings.origin_offset.y) * y_interval
        var y_position: CGFloat = y_origin + y_interval
        
        while y_position < self.layer!.bounds.size.height {
            let start = CGPoint(x: 0, y: y_position)
            let end = CGPoint(x: self.layer!.bounds.size.width, y:y_position)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
            y_position += y_interval
        }
        
        y_position = y_origin - y_interval
        while y_position > 0 {
            let start = CGPoint(x: 0, y: y_position)
            let end = CGPoint(x: self.layer!.bounds.size.width, y:y_position)
            
            grid_path.move(to: start)
            grid_path.addLine(to: end)
            
            // loop
             y_position -= y_interval
        }
        
        //// shape
        let grid_shape = CAShapeLayer()
        grid_shape.path = grid_path
        grid_shape.lineWidth = CGFloat(self.settings.major_line_width)
        grid_shape.fillColor = CGColor.clear
        grid_shape.strokeColor = self.settings.major_line_color.cgColor
        
        if self.grid_layer.superlayer != nil {
            self.grid_layer.removeFromSuperlayer()
        }
        self.grid_layer = grid_shape
        
        self.layer!.addSublayer(self.grid_layer)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath != nil {
            self.refresh()
        }
    }
}
