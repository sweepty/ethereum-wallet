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
    let statusText: PublishSubject<String>
    let walletList: BehaviorSubject<[SectionOfCustomData]>
    
    init() {
        self.statusText = PublishSubject<String>()
        let wallets = ETHWallet.selectAllWallet()
        self.walletList = BehaviorSubject<[SectionOfCustomData]>(value: [SectionOfCustomData(items: wallets)])
    }
}
