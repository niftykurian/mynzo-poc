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
    var window:UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if UserDefaults.standard.bool(forKey: "firstTime") == false{
            UserDefaults.standard.set(true, forKey: "firstTime")
            UserDefaults.standard.set(Date(), forKey: "syncDate")
            Logger.write(text: "first time date setup - \(Date())")
        }
        Logger.write(text: "launched first time  - 10:1pm")
        Logger.write(text: "keys \(launchOptions?.keys)")
        _registerRemoteNotification()
        if let keys = launchOptions?.keys {
            if keys.contains(.location) {
                Logger.write(text: "Application launched by location event")
                _initLocationManager()
                locationManager.startMonitoringSignificantLocationChanges()
            }
        }
        else{
            Logger.write(text: "Application Launched")
            _initLocationManager()
            locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        getactivitytracking()
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        Logger.write(text: ("will resign active"))
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        Logger.write(text: ("will enter foreground"))
        getactivitytracking()
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Logger.write(text: ("Latitude: \(location.coordinate.latitude) , Longitude: \(location.coordinate.longitude)"))
        getactivitytracking()
        // Use the location here
    }
    func _registerRemoteNotification(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                return
            }
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    func _initLocationManager(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startTracking() {
        if CMMotionActivityManager.isActivityAvailable() {
            activityManager.startActivityUpdates(to: OperationQueue.main) { (activity: CMMotionActivity?) in
                if let activity = activity {
                    Logger.write(text:"sync date updated in start activity tracking method with \(Date())")
                    UserDefaults.standard.set(Date(), forKey: "syncDate")
                    Logger.write(text:"value in nsuserdefaults \(UserDefaults.standard.object(forKey: "syncDate"))")
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
                    }else{
                        Logger.write(text: "else activity - \(activity.description)")
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
        Logger.write(text:"remote notification received")
        // Start a background task
        let backgroundTask = application.beginBackgroundTask(withName: "MyBackgroundTask", expirationHandler: {
            // Handle the expiration of the background task
            completionHandler(.failed)
            Logger.write(text:"expiration handler data")
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
        Logger.write(text:"retrieved data")
        Logger.write(text:"requesting data from \(UserDefaults.standard.object(forKey: "syncDate") as! Date) to \(Date())")
        activityManager.queryActivityStarting(from:  UserDefaults.standard.object(forKey: "syncDate") as! Date,
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
            Logger.write(text:"sync date updated in getactivity tracking method with \(Date())")
            UserDefaults.standard.set(Date(), forKey: "syncDate")
            self.startTracking()
        }
    }
}

