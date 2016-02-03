//
//  AppDelegate.swift
//  Shaneglish
//
//  Created by Laurin Brandner on 31/01/16.
//  Copyright © 2016 Laurin Brandner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let navigationController = UINavigationController(rootViewController: TableViewController())
        navigationController.navigationBar.barTintColor = UIColor(red: 29/255, green: 35/255, blue: 57/255, alpha: 1)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController.navigationBar.tintColor = .whiteColor()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = .whiteColor()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

}

