//
//  ViewController+Toast.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-28.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import UIKit

extension UIViewController {
  
  func showToast(message: String, completion: (() -> Void)?) {
    
    let width = UIScreen.main.bounds.width - 40
    let toastLabel = UILabel(
      frame: CGRect(
        x: self.view.frame.size.width / 2 - (width / 2),
        y: self.view.frame.size.height - 50,
        width: width, height: 35
      )
    )
    toastLabel.layer.borderColor = UIColor(white: 1, alpha: 0.6).cgColor
    toastLabel.layer.borderWidth = 1
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = .center;
    toastLabel.font = UIFont.systemFont(ofSize: 12)
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 8;
    toastLabel.clipsToBounds = true
    
    view.addSubview(toastLabel)
    UIView.animate(withDuration: 1.0, delay: 0.1, options: .curveEaseOut, animations: {
      toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
      completion?()
      toastLabel.removeFromSuperview()
    })
  } }
