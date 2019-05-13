//
//  ImportNameViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 13/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImportNameViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusProgressView: UIProgressView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var privateKey = String()
    var disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBind()
    }
    
    private func setupBind() {
        let validatePassword = passwordTextField.rx.text.orEmpty
            .map { $0.validate() }
            .share(replay: 1)
        
        let validateName = nameTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .share(replay: 1)
        
        // status and progress
        validatePassword
            .distinctUntilChanged()
            .subscribe(onNext: { (checker) in
                checker ? self.viewModel.statusText.onNext("Good") : self.viewModel.statusText.onNext("Weak")
                self.statusLabel.textColor = checker ? UIColor.iconMain : UIColor.red
                self.statusProgressView.progress = checker ? 1.0 : 0.3
            })
            .disposed(by: disposeBag)
        
        viewModel.statusText
            .bind(to: self.statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = doneButton
        
        doneButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                // import wallet
                let wallet = ETHWallet.importWallet(privateKey: self.privateKey, password: self.passwordTextField.text!, name: self.nameTextField.text!)
                ETHWallet.insertWallet(wallet: wallet)
                
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(validatePassword.asObservable(), validateName.asObservable())
            .map { pw, name in
                guard pw == false || name == false else {
                    return true
                }
                return false
            }.bind(to: doneButton.rx.isEnabled)
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
