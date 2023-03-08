//
//  AppDelegate.swift
//  mynzo_poc
//
//  Created by Kurian Ninan K on 02/03/23.
//

import UIKit
import CoreLocation
import CoreMotion

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    
    let activityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    var window: UIWindow?
    var locationManager = CLLocationManager()
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    var bgtimer = Timer()
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var current_time = NSDate().timeIntervalSince1970
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        //        Logger.write(text: "keys \(launchOptions?.keys)")
        //        if let keys = launchOptions?.keys {
        //           if keys.contains(.location) {
        //            Logger.write(text: "inside location key loop")
        //              locationManager.delegate = self
        ////              locationManager.startMonitoringVisits()
        //           }
        //        }
        
        //        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        //                // Handle the authorization result
        //            }
        
        if UserDefaults.standard.bool(forKey: "firstTime") == false{
            UserDefaults.standard.set(true, forKey: "firstTime")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "syncDate")
        }
        application.registerForRemoteNotifications()
        if(AppDelegate.hasGivenAllPermissions()){
            StartupdateLocation()
            getactivitytracking()
        }else{
            locationManager.requestWhenInUseAuthorization()
            AppDelegate.checkAllPermissions()
        }
        return true
        
    }
    
    func startTracking() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
                if let activity = activity {
                    //                    Logger.write(text:"sync date updated in start activity tracking method")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "syncDate")
                    //                    if activity.confidence == .high || activity.confidence == .medium{
                    Logger.write(text:"\(activity.description) at \(activity.startDate.toString())")
                    //                    }
                    //                    let confidence = activity.confidence.rawValue
                    // Handle the activity here
                    //                    if activity.walking {
                    //                        Logger.write(text:"User is walking, confidence: \(confidence) at \(activity.startDate.toString())")
                    //                    } else if activity.running {
                    //                        Logger.write(text:"User is running, confidence: \(confidence) at \(activity.startDate.toString())")
                    //                    } else if activity.automotive {
                    //                        Logger.write(text:"User is in a vehicle, confidence: \(confidence) at \(activity.startDate.toString())")
                    //                    } else if activity.stationary {
                    //                        Logger.write(text:"User is stationary, confidence: \(confidence) at \(activity.startDate.toString())")
                    //                    } else if activity.unknown {
                    //                        Logger.write(text:"unknown")
                    //                    }
                    //                    else{
                    ////                        Logger.write(text:"in else condition")
                    ////                        Logger.write(text:"\(activity)")
                    //                        Logger.write(text:"\(activity.description)")
                    //
                    //                    }
                }
            }
        }
    }
    
    func stopTracking() {
        activityManager.stopActivityUpdates()
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
        Logger.write(text:"memory warning")
        // Dispose of any resources that can be recreated.
    }
    func applicationDidBecomeActive(_ application: UIApplication) { AppDelegate.checkAllPermissions()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Start a background task
        //        Logger.write(text:"remote notification")
        let backgroundTask = application.beginBackgroundTask(withName: "MyBackgroundTask", expirationHandler: {
            // Handle the expiration of the background task
            completionHandler(.failed)
            //            Logger.write(text:"expiration handler data")
            self.getactivitytracking()
        })
        self.getactivitytracking()
        // Perform your task here
        DispatchQueue.main.asyncAfter(deadline: .now() + 180) {
            // End the background task
            
            application.endBackgroundTask(backgroundTask)
            completionHandler(.newData)
        }
    }
    
    func getactivitytracking(){
        //        Logger.write(text:"retrieved data")
        //        Logger.write(text:"requesting data from \(Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "syncDate"))) to \(Date())")
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.queryActivityStarting(from: Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "syncDate")),
                                                  to: Date(),
                                                  to: OperationQueue.main) { (motionActivities, error) in
                Logger.write(text:"\(motionActivities?.count ?? 0) activities detected")
                if(motionActivities != nil){
                    for activity in motionActivities! {
                        //                if activity.confidence == .high || activity.confidence == .medium{
                        Logger.write(text:"\(activity.description) at \(activity.startDate.toString())")
                        //                }
                        //                if activity.walking {
                        //                    Logger.write(text:"User is walking, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                        //                } else if activity.running {
                        //                    Logger.write(text:"User is running, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                        //                } else if activity.automotive {
                        //                    Logger.write(text:"User is in a vehicle, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                        //                } else if activity.stationary {
                        //                    Logger.write(text:"User is stationary, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                        //                } else if activity.unknown {
                        //                    Logger.write(text:"unknown")
                        //                }else if let error = error {
                        //                    Logger.write(text:"error: \(error)")
                        //                }
                        //                else{
                        //                    Logger.write(text:"\(activity.description)")
                        //                }
                    }
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "syncDate")
                    
                }
                
                //            Logger.write(text:"sync date updated in getactivity tracking method")
            }
            self.startTracking()
        }
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        locationManager.startMonitoringSignificantLocationChanges()
        activityManager.stopActivityUpdates()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        //        locationManager.requestWhenInUseAuthorization()
        guard AppDelegate.hasGivenAllPermissions() else { return }
        print("Entering Backround")
        self.doBackgroundTask()
    }
    
    func doBackgroundTask() {
        
        DispatchQueue.main.async {
            
            self.beginBackgroundUpdateTask()
            
            self.StartupdateLocation()
            
            self.bgtimer = Timer.scheduledTimer(timeInterval: 1*60, target: self, selector: #selector(AppDelegate.bgtimer(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(self.bgtimer, forMode: RunLoop.Mode.default)
            RunLoop.current.run()
            
            self.endBackgroundUpdateTask()
            
        }
    }
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endBackgroundUpdateTask()
        })
    }
    
    func endBackgroundUpdateTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    }
    
    func StartupdateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while requesting new coordinates")
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager)  {
        if manager.authorizationStatus == .authorizedAlways { return }
        AppDelegate.checkAllPermissions()
        return
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
        Logger.write(text: ("updated location - Latitude: \(self.latitude) , Longitude: \(self.longitude)"))
        
    }
    
    @objc func bgtimer(_ timer:Timer!){
        self.updateLocation()
    }
    
    func updateLocation() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.stopUpdatingLocation()
    }
    
}
extension AppDelegate{
    func hasLocationPermission() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else {
            AlertManager.shared.showLocationServiceDisabled()
            return false
        }
        
        let authorizationStatus: CLAuthorizationStatus?
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .authorizedAlways:
            return true
        default:
            return false
        }
    }
    
    func asklocationPermission() async -> Bool {
        guard !hasLocationPermission() else { return true }
        
        let authorizationStatus: CLAuthorizationStatus?
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
        case .restricted, .denied:
            AlertManager.shared.showLocationDenied()
            return false
        case .authorizedWhenInUse:
            AlertManager.shared.showBackgroundLocationDisabled()
            return false
        case .authorizedAlways:
            return true
        default:
            locationManager.requestWhenInUseAuthorization()
            return false
        }
    }
    static func hasGivenAllPermissions() -> Bool {
        let authorisationResult = SensorManager.shared.hasGivenAllPermissions()
        if case .success() = authorisationResult {
            return true
        } else {
            return false
        }
    }
    static func checkAllPermissions() {
        let authorisationResult = SensorManager.shared.hasGivenAllPermissions()
        if case .success() = authorisationResult {
            //restart location manager
            return
        } else {
            let task = Task{
                await SensorManager.shared.askForRemainingPermission()
                return
            }
            task.cancel()
            
        }
    }
}
