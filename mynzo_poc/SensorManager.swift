//
//  SensorManager.swift
//  mynzo_poc
//
//  Created by Julien on 07/03/23.
//

import Foundation
import CoreMotion
import CoreLocation
import UIKit

//MARK: -

enum PermissionError: Error {
  case unauthorizedLocation
  case unauthorizedActivityManager
  
  var customMessage: String {
    switch self {
    case .unauthorizedLocation:
      return "Background location fetching is not enabled"
    case .unauthorizedActivityManager:
      return "Motion&Fitness tracking is disabled"
    }
  }
}

//MARK: -

class SensorManager: NSObject {
    static var shared = SensorManager()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// Holds the blocks being used to record different hardware reports
    private let operationQueue = OperationQueue()
    
    private(set) var isMonitoring: Bool = false
    //private var updateDataTimer: Timer?
    
    private var motionActivityManager: CMMotionActivityManager?
    private var deviceActivityInfo: CMMotionActivity?
    
    //MARK: -
    
    override init() {
        super.init()
        operationQueue.qualityOfService = .utility
        motionActivityManager = CMMotionActivityManager()
    }
    
    func hasGivenAllPermissions() -> Result<Void, PermissionError> {
        Logger.write(text: "hasGivenAllPermissions check")
        guard appDelegate.hasLocationPermission() else { return .failure(PermissionError.unauthorizedLocation) }
        guard hasMotionActivityManagerPermission() else { return .failure(PermissionError.unauthorizedActivityManager) }
        
        Logger.write(text: "hasGivenAllPermissions: all permissions allowed")
        return .success(())
    }
    
    func askForRemainingPermission() async {
        Logger.write(text: "func SensorManager->askForRemainingPermission called")
     //    guard userDefaults.isUserLoggedIn() else { return }
        let clAuthorised = await appDelegate.asklocationPermission()
        guard clAuthorised else { return }
        if !hasMotionActivityManagerPermission() {
            askMotionActivityManagerPermission { [weak self] (isMotionActivityAvailable, authorized) in
                
                guard isMotionActivityAvailable else {
                    AlertManager.shared.showMotionActivitySensingNotAvailable()
                    return
                }
                
                guard authorized else {
                    AlertManager.shared.showMotionActivityManagerPermissionDisabled()
                    return
                }
                
//                self?.startSensors(shouldDelay: true)
            }
        }
    }
    
}
 
//MARK: -

private extension SensorManager {
  private func hasMotionActivityManagerPermission() -> Bool {
    guard CMMotionActivityManager.isActivityAvailable() else { return false }
    
    switch CMMotionActivityManager.authorizationStatus() {
    case .authorized:
      Logger.write(text: "hasMotionActivityManagerPermission authorizationStatus: authorized")
      return true
    default:
      Logger.write(text: "hasMotionActivityManagerPermission authorizationStatus: unauthorized")
      return false
    }
  }
  
  private func askMotionActivityManagerPermission(completion: @escaping (_ isMotionActivityAvailable: Bool, _ authorized: Bool) -> Void) {
    guard CMMotionActivityManager.isActivityAvailable() else { return completion(false, false) }
    guard !hasMotionActivityManagerPermission() else { return completion(true, true) }
    
    let currentDate = Date()
    let activityManager = CMMotionActivityManager()
    activityManager.queryActivityStarting(from: currentDate, to: currentDate, to: .main) { (_, error) in
      guard  let terror = error else {
        Logger.write(text: "askMotionActivityManagerPermission authorizationStatus: authorized")
        return completion(true, true)
      }
      
      Logger.write(text: "askMotionActivityManagerPermission authorizationStatus: unauthorized")
      let error = terror as NSError
      if error.code == CMErrorMotionActivityNotAvailable.rawValue { completion(false, false) }
      else if error.code == CMErrorMotionActivityNotAuthorized.rawValue { completion(true, false) }
      else if error.code == CMErrorMotionActivityNotEntitled.rawValue { completion(true, false) }
      else { completion(true, false) }
    }
  }
  
}
