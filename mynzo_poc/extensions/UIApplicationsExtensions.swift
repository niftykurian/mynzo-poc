//
//  UIApplicationsExtensions.swift
//  mynzo_poc
//
//  Created by Julien on 07/03/23.
//

import UIKit

extension UIApplication {
    func goToAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        guard canOpenURL(url) else { return }
        open(url, options: [:], completionHandler: nil)
    }
    
    class var topViewController: UIViewController? { return getTopViewController() }
    
    private class func getTopViewController(
        base: UIViewController? = UIApplication.keyWindow?.rootViewController) -> UIViewController? {
            if let nav = base as? UINavigationController { return getTopViewController(base: nav.visibleViewController) }
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController { return getTopViewController(base: selected) }
            }
            if let presented = base?.presentedViewController { return getTopViewController(base: presented) }
            return base
        }
    
    static var keyWindow: UIWindow? {
        return shared.windows.first(where: {$0.isKeyWindow})
    }
}
