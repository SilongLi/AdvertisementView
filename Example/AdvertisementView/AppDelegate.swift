//
//  AppDelegate.swift
//  AdvertisementView
//
//  Created by lisilong on 01/06/2018.
//  Copyright (c) 2018 lisilong. All rights reserved.
//

import UIKit
import AdvertisementView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // 网络
//        let adImageJPGUrl = "http://p5.image.hiapk.com/uploads/allimg/150112/7730-150112143S3.jpg"
//        let adimageGIFUrl = "http://img.ui.cn/data/file/3/4/6/210643.gif"
        // 本地
//        let adImageJPGPath = Bundle.main.path(forResource: "adImage2", ofType: "jpg") ?? ""
        let adImageGifPath = Bundle.main.path(forResource: "adImage3", ofType: "gif") ?? ""
        let _ = AdvertisementView(adUrl: adImageGifPath, isIgnoreCache: false, placeholderImage: nil, completion: { (isGotoDetailView) in
            print(isGotoDetailView)
        })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

