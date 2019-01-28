//
//  Slider.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import UIKit


final class Slider: UISlider {
  override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect
  {
    let unadjustedThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
    let thumbOffsetToApplyOnEachSide = (unadjustedThumbRect.size.width / 2.0) - 4
    let minOffsetToAdd = -thumbOffsetToApplyOnEachSide
    let maxOffsetToAdd = thumbOffsetToApplyOnEachSide
    let offsetForValue = minOffsetToAdd + (maxOffsetToAdd - minOffsetToAdd) * CGFloat(value / (self.maximumValue - self.minimumValue))
    var origin = unadjustedThumbRect.origin
    origin.x += offsetForValue
    return CGRect(origin: origin, size: unadjustedThumbRect.size)
  }
}
