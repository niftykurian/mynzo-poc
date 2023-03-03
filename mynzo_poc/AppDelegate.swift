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
        Logger.write(text: "application launched after final update")
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
        Logger.write(text: ("Latitude: \(location.coordinate.latitude) , Longitude: \(location.coordinate.longitude)"))
        // Use the location here
    }
    
    func startTracking() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
                if let activity = activity {
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "syncDate")
                    let confidence = activity.confidence.rawValue
                    // Handle the activity here
                    if activity.walking {
                        Logger.write(text:"User is walking, confidence: \(confidence) at \(activity.startDate.toString())")
                    } else if activity.running {
                        Logger.write(text:"User is running, confidence: \(confidence) at \(activity.startDate.toString())")
                    } else if activity.automotive {
                        Logger.write(text:"User is in a vehicle, confidence: \(confidence) at \(activity.startDate.toString())")
                    } else if activity.stationary {
                        Logger.write(text:"User is stationary, confidence: \(confidence) at \(activity.startDate.toString())")
                    } else if activity.unknown {
                        Logger.write(text:"unknown")
                    }
                }
            }
        }
    }
    
    func stopTracking() {
        activityManager.stopActivityUpdates()
    }
    
    func didReceiveMemoryWarning() {
        didReceiveMemoryWarning()
        Logger.write(text:"memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Start a background task
        let backgroundTask = application.beginBackgroundTask(withName: "MyBackgroundTask", expirationHandler: {
            // Handle the expiration of the background task
            completionHandler(.failed)
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
        if let _ = UserDefaults.standard.object(forKey: "syncDate") {
            Logger.write(text:"retrieved data")
            activityManager.queryActivityStarting(from: Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "syncDate")),
                                                  to: Date(),
                                                  to: OperationQueue.main) { (motionActivities, error) in
                for activity in motionActivities! {
                    if activity.walking {
                        Logger.write(text:"User is walking, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                    } else if activity.running {
                        Logger.write(text:"User is running, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                    } else if activity.automotive {
                        Logger.write(text:"User is in a vehicle, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                    } else if activity.stationary {
                        Logger.write(text:"User is stationary, confidence: \(activity.confidence.rawValue) at \(activity.startDate.toString())")
                    } else if activity.unknown {
                        Logger.write(text:"unknown")
                    }
                }
            }
            self.startTracking()
        }
    }
}

