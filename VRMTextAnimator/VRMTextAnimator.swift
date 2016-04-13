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
    func textAnimator(textAnimator: VRMTextAnimator, animationDidStart animation: CAAnimation)
    func textAnimator(textAnimator: VRMTextAnimator, animationDidStop animation: CAAnimation)
}

public class VRMTextAnimator: NSObject {
    
    // MARK: Properties
    public var fontName         = "Avenir"
    public var fontSize         : CGFloat = 50.0
    public var textToAnimate    = "Hello Swift!"
    public var textColor        = UIColor.redColor().CGColor
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
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
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
        
        let letters     = CGPathCreateMutable()
        let font        = CTFontCreateWithName(fontName, fontSize, nil)
        let attrString  = NSAttributedString(string: text, attributes: [kCTFontAttributeName as String : font])
        let line        = CTLineCreateWithAttributedString(attrString)
        let runArray    = CTLineGetGlyphRuns(line)
        
        for runIndex in 0..<CFArrayGetCount(runArray) {
            
            let run     : CTRunRef =  unsafeBitCast(CFArrayGetValueAtIndex(runArray, runIndex), CTRunRef.self)
            let dictRef : CFDictionaryRef = unsafeBitCast(CTRunGetAttributes(run), CFDictionaryRef.self)
            let dict    : NSDictionary = dictRef as NSDictionary
            let runFont = dict[kCTFontAttributeName as String] as! CTFont
            
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange  = CFRangeMake(runGlyphIndex, 1)
                var glyph           = CGGlyph()
                var position        = CGPointZero
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                
                let letter          = CTFontCreatePathForGlyph(runFont, glyph, nil)
                var t               = CGAffineTransformMakeTranslation(position.x, position.y)
                CGPathAddPath(letters, &t, letter)
            }
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointZero)
        path.appendPath(UIBezierPath(CGPath: letters))
        
        let pathLayer               = CAShapeLayer()
        pathLayer.frame             = animationLayer.bounds;
        pathLayer.bounds            = CGPathGetBoundingBox(path.CGPath)
        pathLayer.geometryFlipped   = true
        pathLayer.path              = path.CGPath
        pathLayer.strokeColor       = UIColor.blackColor().CGColor
        pathLayer.fillColor         = textColor
        pathLayer.lineWidth         = 1.0
        pathLayer.lineJoin          = kCALineJoinBevel
        
        self.animationLayer.addSublayer(pathLayer)
        self.pathLayer = pathLayer
        
    }
    
    public func startAnimation() {
        let duration = 4.0
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = duration
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self
        pathLayer?.addAnimation(pathAnimation, forKey: "strokeEnd")
        
        let coloringDuration        = 2.0
        let colorAnimation          = CAKeyframeAnimation(keyPath: "fillColor")
        colorAnimation.duration     = duration + coloringDuration
        colorAnimation.values       = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, textColor]
        colorAnimation.keyTimes     = [0, (duration/(duration + coloringDuration)), 1]
        pathLayer?.addAnimation(colorAnimation, forKey: "fillColor")
    }
    
    public func stopAnimation() {
        pathLayer?.removeAllAnimations()
    }
    
    public func clearAnimationText() {
        clearLayer()
    }
    
    public func prepareForAnimation() {
        pathLayer?.removeAllAnimations()
        setupPathLayerWithText(textToAnimate, fontName: fontName, fontSize: fontSize)
        
        let pathAnimation       = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration  = 1.0
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue   = 1.0
        pathAnimation.delegate  = self
        pathLayer?.addAnimation(pathAnimation, forKey: "strokeEnd")
        
        pathLayer?.speed        = 0
        
    }
    
    public func updatePathStrokeWithValue(value: Float) {
        pathLayer?.timeOffset = CFTimeInterval(value)
    }
    
    // MARK: Animation delegate
    public override func animationDidStart(anim: CAAnimation) {
        self.delegate?.textAnimator(self, animationDidStart: anim)
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.delegate?.textAnimator(self, animationDidStop: anim)
    }

}
