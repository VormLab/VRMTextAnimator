//
//  VRMViewController.swift
//  VRMTextAnimator
//
//  Created by Bartosz Olszanowski on 13.04.2016.
//  Copyright © 2016 Vorm. All rights reserved.
//

import UIKit

class VRMViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var drawableView             : UIView!
    @IBOutlet weak var fontPicker               : UIPickerView! {
        didSet {
            fontPicker.delegate                 = self
            fontPicker.dataSource               = self
        }
    }
    @IBOutlet weak var fontSizeTextField        : UITextField! {
        didSet {
            fontSizeTextField.delegate          = self
        }
    }
    @IBOutlet weak var textToAnimateTextField   : UITextField! {
        didSet {
            textToAnimateTextField.delegate     = self
        }
    }
    
    @IBOutlet weak var startAnimationButton     : UIButton! {
        didSet {
            startAnimationButton.layer.cornerRadius     = 8.0
            startAnimationButton.layer.borderWidth      = 1.0
            startAnimationButton.layer.borderColor      = UIColor.whiteColor().CGColor
            startAnimationButton.layer.masksToBounds    = true
        }
    }
    @IBOutlet weak var stopAnimationButton      : UIButton! {
        didSet {
            stopAnimationButton.layer.cornerRadius      = 8.0
            stopAnimationButton.layer.borderWidth       = 1.0
            stopAnimationButton.layer.borderColor       = UIColor.whiteColor().CGColor
            stopAnimationButton.layer.masksToBounds     = true
        }
    }
    @IBOutlet weak var clearTextButton          : UIButton! {
        didSet {
            clearTextButton.layer.cornerRadius          = 8.0
            clearTextButton.layer.borderWidth           = 1.0
            clearTextButton.layer.borderColor           = UIColor.whiteColor().CGColor
            clearTextButton.layer.masksToBounds         = true
        }
    }
    
    
    var textAnimator                            : VRMTextAnimator?
    var isAnimating                             = false
    var chosenFontName                          = "Avenir"
    
    // MARK: VC's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        initTextAnimator()
        updateUI()
        configureTapGesture()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        textAnimator = nil
    }
    
    // MARK: TextAnimator
    func initTextAnimator() {
        textAnimator            = VRMTextAnimator(referenceView: drawableView)
        textAnimator?.delegate  = self
    }
    
    // MARK: Tap gesture
    func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VRMViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Appearance
    
    func updateUI() {
        textToAnimateTextField.placeholder      = textAnimator!.textToAnimate
        fontSizeTextField.placeholder           = String(textAnimator!.fontSize)
        if let animatorFontName = textAnimator?.fontName { chosenFontName = animatorFontName }
        if let chosenFontIndex = UIFont.familyNames().indexOf(chosenFontName) {
            fontPicker.selectRow(chosenFontIndex, inComponent: 0, animated: true)
        }
    }
    
    func updateButtons() {
        startAnimationButton.hidden     = isAnimating
        stopAnimationButton.hidden      = !isAnimating
        clearTextButton.hidden          = isAnimating
    }
    
    // MARK: IBActions
    
    @IBAction func didPressStartAnimationButton(sender: UIButton) {
        startAnimation()
    }
    
    @IBAction func didPressStopAnimationButton() {
        stopAnimation()
    }
    
    @IBAction func didPressClearTextButton() {
        clearText()
    }
    
    // MARK: Animations
    
    func updateTextAnimator() {
        textAnimator?.fontName      = chosenFontName
        if let fontSizeText = fontSizeTextField.text where fontSizeText.characters.count > 0 {
            textAnimator?.fontSize      = CGFloat((fontSizeText as NSString).floatValue)
        } else if let placeholderText = fontSizeTextField.placeholder where placeholderText.characters.count > 0 {
            textAnimator?.fontSize      = CGFloat((placeholderText as NSString).floatValue)
        }
        if let textToAnimateText = textToAnimateTextField.text where textToAnimateText.characters.count > 0 {
            textAnimator?.textToAnimate = textToAnimateText
        } else if let placeholderText = textToAnimateTextField.placeholder where placeholderText.characters.count > 0 {
            textAnimator?.textToAnimate = placeholderText
        }
        
    }
    
    func startAnimation() {
        updateTextAnimator()
        textAnimator?.startAnimation()
    }
    
    func stopAnimation() {
        textAnimator?.stopAnimation()
    }
    
    func clearText() {
        textAnimator?.clearAnimationText()
    }

}

// MARK: UIPickerView delegate & dataSource

extension VRMViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return UIFont.familyNames().count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenFontName = UIFont.familyNames()[row]
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let currentTitle    = UIFont.familyNames()[row]
        let attributes      = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        return NSAttributedString(string: currentTitle, attributes: attributes)
    }
}

// MARK: VRMTextAnimator delegate

extension VRMViewController: VRMTextAnimatorDelegate {
    
    func textAnimator(textAnimator: VRMTextAnimator, animationDidStart animation: CAAnimation) {
        isAnimating = true
        updateButtons()
    }
    
    func textAnimator(textAnimator: VRMTextAnimator, animationDidStop animation: CAAnimation) {
        isAnimating = false
        updateButtons()
    }
    
}

// MARK: UITextField delegate

extension VRMViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

