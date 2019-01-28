//
//  StorageService.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-28.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import Foundation

import FirebaseStorage


class StorageService {
  
  private init() {}
  static let shared = StorageService()

  var videoReference: StorageReference {
    return Storage.storage().reference().child("videos")
  }
  
  func uploadVideo(filename: String, data: Data, completion: @escaping (_ error: Error?) -> Void) {
    
    let uploadVideoRef = videoReference.child(filename)
    
    let uploadTask = uploadVideoRef.putData(data, metadata: nil) { (metadata, error) in
      print("Upload taks completed")
      print(metadata ?? "No metadata")
    }
    
    uploadTask.observe(.success) { (snapshot) in
      completion(snapshot.error)
    }
    
    uploadTask.resume()
  }
  
}
