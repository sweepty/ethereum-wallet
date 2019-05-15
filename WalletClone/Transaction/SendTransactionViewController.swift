//
//  SendTransactionViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 14/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Web3swift
import BigInt

class SendTransactionViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var gasLimitTextField: UITextField!
    @IBOutlet weak var gasPriceSlider: UISlider!
    @IBOutlet weak var maxGasLabel: UILabel!
    
    // status labels
    @IBOutlet weak var amountStatusLabel: UILabel!
    @IBOutlet weak var toStatusLabel: UILabel!
    @IBOutlet weak var gasLimitStatusLabel: UILabel!
    
    @IBOutlet weak var gasPriceLabel: UILabel!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var wallet: Wallet? = nil
    
    var password = String()
    
    var disposeBag = DisposeBag()
    
    public let viewModel = TransactionViewModel()
    
    let defaultGasLimit: BigUInt = BigUInt(21000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        setupUI()
        setupBind()
        
        if let isAddress = UIPasteboard.general.string, EthereumAddress(isAddress)?.isValid == true {
            self.toTextField.text = isAddress
        }
    }
    
    private func setupUI() {
        // GAS PRICE
        self.gasPriceSlider.minimumValue = 1.0
        self.gasPriceSlider.maximumValue = 99.0
        self.gasPriceSlider.value = 21.0
    }
    
    private func setupBind() {
        viewModel.balance
            .map { String($0) }
            .bind(to: self.balanceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.gasLimit
            .map { String($0) }
            .bind(to: self.gasLimitTextField.rx.text)
            .disposed(by: disposeBag)
        
        // amount check
        amountTextField.rx.text.orEmpty
            .debounce(0.2, scheduler: MainScheduler.instance)
            .map { BigUInt($0) ?? 0 }
            .bind(to: viewModel.amount)
            .disposed(by: disposeBag)
        
        viewModel.toStatus
            .bind(to: self.toStatusLabel.rx.text)
            .disposed(by: disposeBag)
        
        gasPriceSlider.rx.value
            .map { Int($0) }
            .bind(to: viewModel.gasPrice)
            .disposed(by: disposeBag)
        
        viewModel.gasPrice
            .map { String($0) }
            .bind(to: gasPriceLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.amountStaus
            .bind(to: amountStatusLabel.rx.text)
            .disposed(by: disposeBag)
        
        gasLimitTextField.rx.text.orEmpty
            .map { BigUInt($0)! }
            .bind(to: viewModel.gasLimit)
            .disposed(by: disposeBag)
        
        viewModel.avaliable
            .bind(to: sendButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        // amount status
        viewModel.avaliable
            .map { !$0 }
            .bind(to: amountStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // to address check
        let toStatus = toTextField.rx.text.orEmpty.share(replay: 1)
        
        toStatus
            .map { EthereumAddress($0)?.isValid ?? false }
            .bind(to: toStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // 입력을 완료했을 때로 변경하기
        toStatus
            .subscribe(onNext: { (address) in
                if EthereumAddress(address)?.isValid ?? false {
                    self.viewModel.toStatus.onNext("good")
                } else {
                    self.viewModel.toStatus.onNext("유효하지 않은 주소입니다.")
                }
            }).disposed(by: disposeBag)
        
        let gasStatus = gasLimitTextField.rx.text.orEmpty
            .map { Int($0)! >= 0 }
            .share(replay: 1)
        
        gasStatus
            .map { $0 }
            .bind(to: gasLimitStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        gasStatus
            .subscribe(onNext: { (checker) in
                checker ? self.viewModel.gasStatus.onNext("aaa") : self.viewModel.gasStatus.onNext("가스 한도를 입력해주세요.")
            }).disposed(by: disposeBag)
        
        
        sendButton.rx.controlEvent(.touchUpInside)
            .subscribe { (_) in
                let gasPrice = BigUInt(self.gasPriceSlider.value)
                let gasLimit = BigUInt(self.gasLimitTextField.text ?? "0")
                
                // default policies
                var pricePolicy: TransactionOptions.GasPricePolicy = .automatic
                var limitPolicy: TransactionOptions.GasLimitPolicy = .automatic
                
                if gasPrice != 21 {
                    pricePolicy = .manual(gasPrice)
                }
                
                if gasLimit != self.defaultGasLimit {
                    limitPolicy = .manual(gasLimit!)
                }
                
//                let tx = ETHWallet.generateSendTransaction(value: self.amountTextField.text!, fromAddressString: self.wallet!.address, toAddressString: self.toTextField.text!, gasPrice: pricePolicy, gasLimit: limitPolicy)
                let tx = ETHWallet.generateSendTransaction(value: "1.0", fromAddressString: self.wallet!.address, toAddressString: self.toTextField.text!, gasPrice: .automatic, gasLimit: .automatic)
                
//                let txResult = ETHWallet.sendTransaction(transaction: tx, password: self.password)
//
////                Observable.just(ETHWallet.sendTransaction(transaction: tx, password: self.password))
////                    .bind(to: viewModel.result)
////                    .dis
                
                self.viewModel.result.onNext(ETHWallet.sendTransaction(transaction: tx, password: self.password)!)
                
                let txResultVC = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "TxResult") as! TxResultViewController
                
                self.present(txResultVC, animated: true, completion: nil)
                
            }.disposed(by: disposeBag)
        viewModel.balance.onNext(BigUInt(Ethereum.getBalance(walletAddress: self.wallet!.address)!)!)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
