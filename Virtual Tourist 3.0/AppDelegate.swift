//
//  AppDelegate.swift
//  Virtual Tourist 3.0
//
//  Created by Zakaria on 25/11/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    
    let dataControllerClass = DataControllerClass(modelName: "VirtualTouristDataM")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // load the persistent store
        dataControllerClass.load()
        
        
        let navigationController = window?.rootViewController as! UINavigationController
        let travelMapVC = navigationController.topViewController as! TravelMapViewController
        travelMapVC.dataControllerClass = dataControllerClass
        
        print("\(navigationController.viewControllers) navigation controller controllers")

        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    // save any unsaved changes
    func saveViewContext(){
        try? dataControllerClass.viewContext.save()
    }

}

