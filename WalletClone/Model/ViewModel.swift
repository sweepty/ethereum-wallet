//
//  ViewModel.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 02/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Web3swift

class ViewModel {
    let statusText: BehaviorSubject<String>
    let walletList: BehaviorSubject<[Wallet]>
    
    init() {
        self.statusText = BehaviorSubject<String>(value: "Weak")
        let wallets = ETHWallet.selectAllWallet()
        self.walletList = BehaviorSubject<[Wallet]>(value: wallets)
    }
}
