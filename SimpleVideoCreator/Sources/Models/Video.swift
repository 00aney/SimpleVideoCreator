//
//  Video.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-26.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import Foundation


struct Video: Codable {
  var id: String? = nil
  
  let title: String
  let length: String
  let resolution: String
  let format: String
  
  init(title: String, length: String, resolution: String, format: String) {
    self.title = title
    self.length = length
    self.resolution = resolution
    self.format = format
  }
}

