//
//  CreateWalletViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 08/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Web3swift

class CreateWalletViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    // keyboard next trigger
    @IBAction func textFieldPrimaryActionTrigger(_ sender: Any) {
        if nextBarButton.isEnabled {
            let nextVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "WalletName") as! WalletNameViewController
            nextVC.password = self.passwordTextField.text!
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            passwordTextField.backgroundColor = UIColor.red
        }
    }
    
    var disposeBag = DisposeBag()
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.isSecureTextEntry = true
        
        self.viewModel.statusText
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        setupUI()
        validatePassword()
        setupBind()
    }
    
    private func setupUI() {
        let rightButton  = UIButton(type: .detailDisclosure)
        rightButton.frame = CGRect(x:0, y:0, width:30, height:30)
        passwordTextField.rightViewMode = .whileEditing
        passwordTextField.rightView = rightButton
        
        rightButton.rx.controlEvent(.touchUpInside)
            .subscribe { (x) in
                self.passwordTextField.isSecureTextEntry.toggle()
            }.disposed(by: disposeBag)
    }
    
    private func setupBind() {
        cancelBarButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                self.navigationController?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)

        nextBarButton.rx.tap.asControlEvent()
            .subscribe { (x) in
                let nextVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "WalletName") as! WalletNameViewController
                nextVC.password = self.passwordTextField.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func validatePassword() {
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map { $0.validate() }
            .share(replay: 1)
        
        passwordValid
            .distinctUntilChanged()
            .subscribe(onNext: { (x) in
                x ? self.viewModel.statusText.onNext("Good😎") : self.viewModel.statusText.onNext("Weak🤔")
                self.statusLabel.textColor = x ? .blue : .red
                self.progressView.progress = x ? 1.0 : 0.3
                
                if x {
                    self.passwordTextField.backgroundColor = UIColor.iconMain
                }
            })
            .disposed(by: disposeBag)
        
        passwordValid
            .bind(to: nextBarButton.rx.isEnabled)
            .disposed(by: disposeBag)
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
