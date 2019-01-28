//
//  Encodable+toDictionary.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import Foundation


extension Encodable {
  
  func toDictinary(excluding keys: [String] = [String]()) throws -> [String: Any] {
    let objectData = try JSONEncoder().encode(self)
    let jsonOBject = try JSONSerialization.jsonObject(with: objectData, options: [])
    guard var dict = jsonOBject as? [String: Any] else { throw AppError.encodingError }
    
    for key in keys {
      dict[key] = nil
    }
    
    return dict
  }

}
