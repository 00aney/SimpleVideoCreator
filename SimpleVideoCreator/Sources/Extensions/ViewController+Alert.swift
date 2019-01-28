//
//  ViewController+Alert.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import UIKit


extension UIViewController {
 
  @discardableResult public func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    var allButtons = buttonTitles ?? [String]()
    if allButtons.count == 0 {
      allButtons.append("OK")
    }
    
    for index in 0..<allButtons.count {
      let buttonTitle = allButtons[index]
      let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
        completion?(index)
      })
      alertController.addAction(action)
      // Check which button to highlight
      if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
        if #available(iOS 9.0, *) {
          alertController.preferredAction = action
        }
      }
    }
    present(alertController, animated: true, completion: nil)
    return alertController
  }
  
}
