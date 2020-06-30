//
//  AppDelegate.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var locationManager = LocationManager.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        log.info("launchOptions=\(launchOptions?.debugDescription ?? "nil")")

        let mapApiKey = "AIzaSyBW0EOM_0yqnk3OklaQEo4yJBUm_gbGfHA"
        GMSServices.provideAPIKey(mapApiKey)

        if launchOptions?[.location] is NSNumber {
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.startUpdate()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

