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

@IBDesignable
class RoundButton: UIButton {
    @IBInspectable var cornerRadius: Double {
        get {
            return Double(self.layer.cornerRadius)
        } set {
            self.layer.cornerRadius = CGFloat(self.layer.bounds.height/10)
        }
    }
}

@IBDesignable
class suffixTextField: UITextField {
    @IBInspectable var suffix: String? {
        didSet {
            updateSuffix()
        }
    }
    
    @IBInspectable var fieldHeight: CGFloat {
        get {
            return self.frame.size.height
        } set {
            self.frame.size.height = newValue
        }
    }
    private func updateSuffix() {
        rightViewMode = UITextField.ViewMode.always
        if let text = suffix {
            // Bounds of suffix
            let labelFrame = CGRect(x: 0, y: 0, width: 50, height: self.bounds.height)
            let label = UILabel(frame: labelFrame)
            label.font = label.font.withSize(20)
            label.text = text
            label.textColor = .gray
            rightView = label
        }
    }
}
