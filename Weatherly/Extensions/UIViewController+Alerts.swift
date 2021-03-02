//
//  UIViewController+Alerts.swift
//  Weatherly
//
//  Created by Jason Silver on 1/3/21.
//

import Foundation
import UIKit

extension UIViewController {

    /// This displays an error alert on the ViewController
    /// - Parameter message: The message to be shown on the UIAlert
    func displayErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "There was a slight hiccup", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }

}
