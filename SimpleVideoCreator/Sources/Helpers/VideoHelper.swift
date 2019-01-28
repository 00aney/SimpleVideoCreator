//
//  VideoHelper.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import AVFoundation
import MobileCoreServices
import UIKit


struct VideoHelper {
  
  static func startMediaBrowser(delegate: UIViewController & UINavigationControllerDelegate & UIImagePickerControllerDelegate, sourceType: UIImagePickerController.SourceType) {
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
    
    let imagePickerViewController = UIImagePickerController()
    imagePickerViewController.sourceType = sourceType
    imagePickerViewController.mediaTypes = [kUTTypeMovie as String]
    imagePickerViewController.allowsEditing = true
    imagePickerViewController.delegate = delegate
    delegate.present(imagePickerViewController, animated: true, completion: nil)
  }
  
}
