//
//  CAAnimationExt.swift
//  TymeXUIComponent
//
//  Created by Linh Tran on 16/12/2023.
//  Copyright © 2023 TymeDigital Vietnam. All rights reserved.
//

import UIKit

/// Enumeration for Core Animation key path.
public enum TymeXAnimationKeyPath: String {
    // Positions
    case position = "position"
    case positionX = "position.x"
    case positionY = "position.y"
    // Transforms
    case transform = "transform"
    case rotation  = "transform.rotation"
    case rotationX = "transform.rotation.x"
    case rotationY = "transform.rotation.y"
    case rotationZ = "transform.rotation.z"
    case scale  = "transform.scale"
    case scaleX = "transform.scale.x"
    case scaleY = "transform.scale.y"
    case scaleZ = "transform.scale.z"
    case translation  = "transform.translation"
    case translationX = "transform.translation.x"
    case translationY = "transform.translation.y"
    case translationZ = "transform.translation.z"
    // Stroke
    case strokeEnd = "strokeEnd"
    case strokeStart = "strokeStart"
    // Other properties
    case opacity = "opacity"
    case path = "path"
    case lineWidth = "lineWidth"
}

public extension CABasicAnimation {
    convenience init(keyPath: TymeXAnimationKeyPath) {
        self.init(keyPath: keyPath.rawValue)
    }
}

public extension CAKeyframeAnimation {
    convenience init(keyPath: TymeXAnimationKeyPath) {
        self.init(keyPath: keyPath.rawValue)
    }
}
