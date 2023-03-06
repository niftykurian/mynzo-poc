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
    
    let locationManager = CLLocationManager()
    let activityManager = CMMotionActivityManager()
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    
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
//        Logger.write(text: "application launched after final update - 12:50 pm - 6 march")
        application.registerForRemoteNotifications()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        getactivitytracking()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Logger.write(text: ("updated location - Latitude: \(location.coordinate.latitude) , Longitude: \(location.coordinate.longitude)"))
//        getactivitytracking()
//        getactivitytracking()
        // Use the location here
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
            //            Logger.write(text:"sync date updated in getactivity tracking method")
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "syncDate")
        }
            self.startTracking()
        }
    }
    
//    func applicationWillTerminate(_ application: UIApplication) {
//        activityManager.stopActivityUpdates()
//    }
}

