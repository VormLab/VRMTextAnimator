//
//  VRMSliderViewController.swift
//  VRMTextAnimator
//
//  Created by Bartosz Olszanowski on 13.04.2016.
//  Copyright © 2016 Vorm. All rights reserved.
//

import UIKit

class VRMSliderViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var drawableView             : UIView!
    @IBOutlet weak var slider                   : UISlider!
    
    var textAnimator                            : VRMTextAnimator?
    
    // MARK: VC's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layoutIfNeeded()
        initTextAnimator()
        slider.value = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textAnimator = nil
    }
    
    // MARK: TextAnimator
    
    func initTextAnimator() {
        textAnimator = VRMTextAnimator(referenceView: drawableView)
        textAnimator?.prepareForAnimation()
    }
    
    // MARK: IBActions
    
    @IBAction func didChangeSliderValue(_ sender: UISlider) {
        guard let textAnimator = textAnimator else { return }
        textAnimator.updatePathStrokeWithValue(value: sender.value)
    }

}
