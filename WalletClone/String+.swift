//
//  String+.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 02/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation

extension String {
    // 8글자 이상
    // 대문자, 소문자, 숫자 1개 이상 포함
    // 특수문자 포함
    func vaildate() -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()\\-_=+{}|?>.<,:;~`’])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        let result = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
        return result
    }
}
