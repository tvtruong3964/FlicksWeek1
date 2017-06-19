//
//  AppDelegate.swift
//  FlicksWeek1
//
//  Created by Truong Tran on 6/16/17.
//  Copyright © 2017 Truong Tran. All rights reserved.
//

import UIKit
import AFNetworking
import RMessage

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataModel = DataModel()
    let NetworkReachabilityChanged = NSNotification.Name("NetworkReachabilityChanged")
    var previousNetworkReachabilityStatus: AFNetworkReachabilityStatus = .unknown

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let tabBarController = window!.rootViewController as! UITabBarController
        if let tabBarViewController = tabBarController.viewControllers {
            
           let nowPlayingNavigationController = tabBarViewController[0] as! UINavigationController
            let nowPlayingController = nowPlayingNavigationController.viewControllers[0] as! NowPlayingMovieViewController
            nowPlayingController.dataModel = dataModel
        
            let topRatedNavigationController = tabBarViewController[1] as! UINavigationController
            let topRateController = topRatedNavigationController.viewControllers[0] as! TopRatedMovieViewController
            topRateController.dataModel = dataModel
//
//            
//            let movieNavigationController = tabBarViewController[2] as! UINavigationController
//            let movieController = movieNavigationController.viewControllers[0] as! MovieViewController
//            movieController.dataModel = dataModel

            
            
        }
//        let navigationController = window!.rootViewController as! UINavigationController
//        let controller = navigationController.viewControllers[0] as! NowPlayingMovieViewController
//        controller.dataModel = dataModel
//        RMessageView.appearance().alpha = 0.4
//        RMessageView.appearance().backgroundColor = UIColor(red: 233/255, green: 82/255, blue: 84/255, alpha: 1)
        
        return true
    }
    
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

