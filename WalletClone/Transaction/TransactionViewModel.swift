//
//  TransactionViewModel.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 14/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import BigInt
import Web3swift

class TransactionViewModel {
    let balance: PublishSubject<BigUInt>
    let amount: PublishSubject<BigUInt>
    // Gwei
    let gasLimit: BehaviorSubject<BigUInt>
    let gasPrice: BehaviorSubject<Int>
    
    let amountStaus: PublishSubject<String>
    let toStatus: PublishSubject<String>
    let gasStatus: PublishSubject<String>
    
    let estimatedGas: PublishSubject<String>
    
    let avaliable: PublishSubject<Bool>
    
    let result: PublishSubject<TransactionSendingResult>
    
    let disposeBag = DisposeBag()
    init() {
        self.balance = PublishSubject<BigUInt>()
        self.amount = PublishSubject<BigUInt>()
        self.gasLimit = BehaviorSubject<BigUInt>(value: 210000)
        self.gasPrice = BehaviorSubject<Int>(value: 21)
        
        // status
        self.amountStaus = PublishSubject<String>()
        self.toStatus = PublishSubject<String>()
        self.gasStatus = PublishSubject<String>()
        
        self.estimatedGas = PublishSubject<String>()
        self.avaliable = PublishSubject<Bool>()
        
        self.result = PublishSubject<TransactionSendingResult>()

        Observable.combineLatest(balance, amount, gasLimit)
            .map { $0.1*1000000000 + $0.2 > $0.0*1000000000 }
            .bind(to: self.avaliable)
            .disposed(by: disposeBag)
        
        avaliable.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { (checker) in
                checker ? self.amountStaus.onNext("보유 수량보다 작은 값을 입력하세요.") : self.amountStaus.onNext("GOOD")
            }).disposed(by: disposeBag)
        
    }
}
