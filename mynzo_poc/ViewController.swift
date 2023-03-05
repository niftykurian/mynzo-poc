//
//  ViewController.swift
//  mynzo_poc
//
//  Created by Kurian Ninan K on 02/03/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func buttonShare(_ sender: Any) {
        let fileURL = NSURL(fileURLWithPath: UserDefaults.standard.string(forKey: "filePath") ?? "")

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the file to the Array
        filesToShare.append(fileURL)

        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)

        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

