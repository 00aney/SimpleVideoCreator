//
//  Snapshot+decode.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import Foundation

import FirebaseFirestore


extension DocumentSnapshot {
  
  func decode<T: Decodable>(as objectType: T.Type, includingID: Bool = true) throws -> T {
    
    var documentJSON = data()
    if includingID {
      documentJSON?["id"] = documentID
    }
    
    let documentData = try JSONSerialization.data(withJSONObject: documentJSON as Any, options: [])
    let decodedObject = try JSONDecoder().decode(objectType, from: documentData)
    
    return decodedObject
  }
  
}
