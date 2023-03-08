//
//  AlertManager.swift
//  mynzo_poc
//
//  Created by Julien on 07/03/23.
//

import UIKit

 final class AlertManager: NSObject {
  
  static let shared = AlertManager()
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  
  private override init() {}
  
  //MARK: -
  
   func showLocationServiceDisabled() {
    let title = "Location services disabled"
    let message = "LocationServices not enabled. Users can enable or disable location services by toggling the Location Services switch in Settings -> Privacy"
    let buttons = ["Ok"]
    
    showAlertWithAction(title: title, message: message, buttons: buttons) { _ in }
  }
  
   func showLocationDenied() {
    let title = "Location services are off"
    let message = "To use background location, you must enable 'Always' in the Location Services settings"
    let buttons = ["Settings", "Cancel"]
    
    showAlertWithAction(title: title, message: message, buttons: buttons) { [weak self] (index) in
      switch index {
      case 0: self?.goToAppSettings()
      case 1: break
      default: break
      }
    }
  }
  
   func showBackgroundLocationDisabled() {
    let title = "Background location is not enabled"
    let message = "To use background location, you must enable 'Always' in the Location Services settings"
    let buttons = ["Settings", "Cancel"]
    
    showAlertWithAction(title: title, message: message, buttons: buttons) { [weak self] (index) in
      switch index {
      case 0: self?.goToAppSettings()
      case 1: break
      default: break
      }
    }
  }
  
   func showMotionActivitySensingNotAvailable() {
    let title = "Motion&Fitness tracking not available"
    let message = "Your device not support this feature"
    let buttons = ["Ok"]
    
    showAlertWithAction(title: title, message: message, buttons: buttons) { index in
      switch index {
      default: break
      }
    }
  }
  
   func showMotionActivityManagerPermissionDisabled() {
    let title = "Motion&Fitness tracking is disabled"
    let message = "To analyze your motion status and access your activities like walking, automotive etc.., you must enable 'Motion & Fitness' in the app's settings"
    let buttons = ["Settings", "Cancel"]
    
    showAlertWithAction(title: title, message: message, buttons: buttons) { [weak self] (index) in
      switch index {
      case 0: self?.goToAppSettings()
      case 1: break
      default: break
      }
    }
  }
  
  //MARK: -
  
   private func showAlertWithAction(title: String?, message: String?, style: UIAlertController.Style = .alert, buttons: [String], completion: ((Int) -> Void)?) {
       DispatchQueue.main.async   {
      let alert = UIAlertController(title: title, message: message, preferredStyle: style)
      for (i, title) in buttons.enumerated() {
        let action = UIAlertAction(title: title, style: UIAlertAction.Style.default) { _ in
          completion?(i)
        }
        alert.addAction(action)
      }
        self.appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
  }
     
     
  private func goToAppSettings() {
    DispatchQueue.main.async {
        self.appDelegate.window?.rootViewController?.dismiss(animated: true, completion: {
        UIApplication.shared.goToAppSettings()
      })
    }
  }
}
