//
//  AppDelegate.swift
//  aspace
//
//  Created by Fedor Paretsky on 10/1/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

import UIKit
import Instabug
import Intercom
import CoreLocation
import DropDown
import Foundation
import MapKit
import CoreLocation
import Mapbox
import SHSearchBar
import MapboxGeocoder
import DropDown
import CircleMenu
import SwiftyJSON
import Alamofire
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import GooglePlaces
import Pageboy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var locationManager: CLLocationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Intercom.setApiKey("ios_sdk-9db3815efc7d39e14289e016a1c346e45ea530be", forAppId:"***REMOVED***")
        Instabug.start(withToken: "9a0192e6ba004fe7b5c5fe2a79710f56", invocationEvents: [.shake, .screenshot])
        
        DropDown.startListeningToKeyboard()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        GMSPlacesClient.provideAPIKey("AIzaSyDLfswWwzcnWIwQ9GMvXDYjbhQY6QUduSA")
        if (Defaults.getUserSession.isValid()) {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mapController: MapController = mainStoryboard.instantiateViewController(withIdentifier: "mapViewController") as! MapController
            self.window?.rootViewController = mapController
            self.window?.makeKeyAndVisible()
        } else {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginPhoneController: LoginPhoneViewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginPhoneViewController") as! LoginPhoneViewController
            self.window?.rootViewController = loginPhoneController
            self.window?.makeKeyAndVisible()
        }
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {return}
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
}

