//
//  VRMTextAnimator.swift
//  VRMTextAnimator
//
//  Created by Bartosz Olszanowski on 13.04.2016.
//  Copyright © 2016 Vorm. All rights reserved.
//

import UIKit
import CoreFoundation

public protocol VRMTextAnimatorDelegate {
    func textAnimator(_ textAnimator: VRMTextAnimator, animationDidStart animation: CAAnimation)
    func textAnimator(_ textAnimator: VRMTextAnimator, animationDidStop animation: CAAnimation)
}

public class VRMTextAnimator: NSObject, CAAnimationDelegate {
    
    // MARK: Properties
    public var fontName         = "Helvetica"
    public var fontSize         : CGFloat = 50.0
    public var textToAnimate    = "HelloSwift!"
    public var textColor        = UIColor.red.cgColor
    public var delegate         : VRMTextAnimatorDelegate?
    
    private var animationLayer  = CALayer()
    private var pathLayer       : CAShapeLayer?
    private var referenceView   : UIView
    
    // MARK: Initialization
    init(referenceView: UIView) {
        self.referenceView          = referenceView
        super.init()
        defaultConfiguration()
    }
    
    deinit {
        clearLayer()
    }
    
    // MARK: Configuration
    private func defaultConfiguration() {
        animationLayer          = CALayer()
        animationLayer.frame    = referenceView.bounds
        referenceView.layer.addSublayer(animationLayer)
        setupPathLayerWithText(text: textToAnimate, fontName: fontName, fontSize: fontSize)
    }

    // MARK: Animations
    
    private func clearLayer() {
        if let _ = pathLayer {
            pathLayer?.removeFromSuperlayer()
            pathLayer = nil
        }
    }
    
    private func setupPathLayerWithText(text: String, fontName: String, fontSize: CGFloat) {
        clearLayer()
        
        let letters     = CGMutablePath()
        let font        = CTFontCreateWithName(fontName as CFString, fontSize, nil)
        let attrString  = NSAttributedString(string: text, attributes: [NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String) : font])
        let line        = CTLineCreateWithAttributedString(attrString)
        let runArray    = CTLineGetGlyphRuns(line)
        
        for runIndex in 0..<CFArrayGetCount(runArray) {
            
            let run     : CTRun =  unsafeBitCast(CFArrayGetValueAtIndex(runArray, runIndex), to: CTRun.self)
            let dictRef : CFDictionary = CTRunGetAttributes(run)
            let dict    : NSDictionary = dictRef as NSDictionary
            let runFont = dict[kCTFontAttributeName as String] as! CTFont
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange  = CFRangeMake(runGlyphIndex, 1)
                var glyph           = CGGlyph()
                var position        = CGPoint.zero
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                let letter          = CTFontCreatePathForGlyph(runFont, glyph, nil)
                let t               = CGAffineTransform(translationX: position.x, y: position.y)
                letters.addPath(letter!, transform: t)
            }
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.append(UIBezierPath(cgPath: letters))
        
        let pathLayer               = CAShapeLayer()
        pathLayer.frame             = animationLayer.bounds;
        pathLayer.bounds            =  path.cgPath.boundingBox
        pathLayer.isGeometryFlipped   = true
        pathLayer.path              = path.cgPath
        pathLayer.strokeColor       = UIColor.black.cgColor
        pathLayer.fillColor         = textColor
        pathLayer.lineWidth         = 1.0
        pathLayer.lineJoin          = kCALineJoinBevel
        
        self.animationLayer.addSublayer(pathLayer)
        self.pathLayer = pathLayer
        
    }
    
    public func startAnimation() {
        let duration = 4.0
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(text: textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = duration
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self as CAAnimationDelegate
        pathLayer?.add(pathAnimation, forKey: "strokeEnd")
        
        let coloringDuration        = 2.0
        let colorAnimation          = CAKeyframeAnimation(keyPath: "fillColor")
        colorAnimation.duration     = duration + coloringDuration
        
        colorAnimation.values       = [UIColor.clear.cgColor, UIColor.clear.cgColor, textColor]
        colorAnimation.keyTimes     = [0, (NSNumber(value: duration/(duration + coloringDuration))), 1]
        pathLayer?.add(colorAnimation, forKey: "fillColor")
    }
    
    public func stopAnimation() {
        pathLayer?.removeAllAnimations()
    }
    
    public func clearAnimationText() {
        clearLayer()
    }
    
    public func prepareForAnimation() {
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(text: textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = 1.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self as CAAnimationDelegate
        pathLayer?.add(pathAnimation, forKey: "strokeEnd")
        
        pathLayer?.speed        = 0
        
    }
    
    public func updatePathStrokeWithValue(value: Float) {
        pathLayer?.timeOffset = CFTimeInterval(value)
    }
    
    // MARK: Animation delegate
    public func animationDidStart(_ anim: CAAnimation) {
        self.delegate?.textAnimator(self, animationDidStart: anim)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.delegate?.textAnimator(self, animationDidStop: anim)
    }

}
