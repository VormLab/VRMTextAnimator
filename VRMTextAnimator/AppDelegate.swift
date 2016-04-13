//
//  AppDelegate.swift
//  VRMTextAnimator
//
//  Created by Bartosz Olszanowski on 13.04.2016.
//  Copyright © 2016 Vorm. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UITabBar.appearance().tintColor = UIColor(red: 0, green: 221.0 / 255.0, blue: 10.0 / 255.0, alpha: 1.0)
        
        return true
    }

}

