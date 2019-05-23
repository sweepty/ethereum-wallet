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
    @IBOutlet weak var cancelButton: UIButton!
    
    var wallet: Wallet? = nil
    
    var password = String()
    
    var disposeBag = DisposeBag()
    
    public let viewModel = TransactionViewModel()
    
    let defaultGasLimit: BigUInt = BigUInt(21000)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBind()
        
        if let isAddress = UIPasteboard.general.string, EthereumAddress(isAddress)?.isValid == true {
            self.toTextField.text = isAddress
        }
    }
    
    private func setupUI() {
        self.sendButton.isEnabled = false
        self.sendButton.backgroundColor = UIColor.gray
        
        self.toStatusLabel.isHidden = true
        self.toStatusLabel.text = ""
        
        self.amountTextField.delegate = self
        self.gasLimitTextField.delegate = self
        
        // GAS PRICE
        self.gasPriceSlider.minimumValue = 1.0
        self.gasPriceSlider.maximumValue = 99.0
        self.gasPriceSlider.value = 21.0
        
        self.amountTextField.becomeFirstResponder()
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
        
        Observable.combineLatest(viewModel.avaliable, viewModel.toAvaliable)
            .subscribe(onNext: { (a, b) in
                if a == true && b == true {
                    self.sendButton.rx.isEnabled.onNext(true)
                    self.sendButton.rx.backgroundColor.onNext(UIColor.iconMain)
                } else {
                    self.sendButton.rx.isEnabled.onNext(false)
                    self.sendButton.rx.backgroundColor.onNext(UIColor.gray)
                }
            })
            .disposed(by: disposeBag)
        
        // amount status
        viewModel.avaliable
            .bind(to: amountStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.toAvaliable
            .distinctUntilChanged()
            .bind(to: toStatusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // to address check
        let toStatus = toTextField.rx.text.orEmpty.share(replay: 1)
        let toTest = toTextField.rx.controlEvent(.editingDidEnd)
        
        toTest.subscribe(onNext: { (_) in
                toStatus
                    .map { EthereumAddress($0)?.isValid ?? false }
                    .bind(to: self.viewModel.toAvaliable)
                    .disposed(by: self.disposeBag)
            
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
        
        
        sendButton.rx.tap
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
                
                ETHWallet.sendTransaction(value: self.amountTextField.text!, fromAddressString: self.wallet!.address,
                                                   toAddressString: self.toTextField.text!, gasPricePolicy: pricePolicy,
                                                   gasLimitPolicy: limitPolicy, password: self.password,
                                                   wallet: self.wallet!, completion: { (result) in
                switch result {
                    case .success(let txResult):
                        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TxResult") as! TxResultViewController
                        nextVC.txResult = txResult
                        nextVC.modalTransitionStyle = .crossDissolve
                        nextVC.modalPresentationStyle = .overCurrentContext
                        self.present(nextVC, animated: true, completion: nil)

                    case .failure(let error):
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(cancel)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                    // 테스트용
//                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TxResult") as! TxResultViewController
//                nextVC.modalTransitionStyle = .crossDissolve
//                nextVC.modalPresentationStyle = .overCurrentContext
//                self.present(nextVC, animated: true, completion: nil)
                
            }.disposed(by: disposeBag)
        
        cancelButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { (_) in
                self.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        viewModel.balance.onNext(BigUInt(Double(Ethereum.getBalance(walletAddress: self.wallet!.address)!)!))
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

extension SendTransactionViewController: UITextFieldDelegate {
    // 숫자와 decimal(1번)만 가능하도록 함.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var invalidCharacters = CharacterSet()
        
        switch textField {
        case self.amountTextField:
            invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
            
            if let dots = textField.text?.components(separatedBy: ".") , dots.count > 1 && string == "." {
                return false
            }
            return string.rangeOfCharacter(from: invalidCharacters) == nil
            
        case self.gasLimitTextField:
            invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
            return string.rangeOfCharacter(from: invalidCharacters) == nil
        default:
            return true
        }
    }
}
