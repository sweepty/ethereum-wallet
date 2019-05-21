//
//  DesignableTest.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 14/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Circle: UIView {
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        }set {
            self.layer.cornerRadius = CGFloat(self.layer.bounds.width/2)
        }
    }
}

@IBDesignable
class CardView: UIView {
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        } set {
            self.layer.cornerRadius = CGFloat(self.layer.bounds.width/30)
        }
    }
}
