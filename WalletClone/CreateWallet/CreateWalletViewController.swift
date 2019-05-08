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
    
    var disposeBag = DisposeBag()
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 잠시 regex 체크
//        passwordTextField.isSecureTextEntry = true
        
        self.viewModel.statusText
            .bind(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
        
        validatePassword()
        setupBind()
    }
    
    private func setupBind() {

        nextBarButton.rx.tap.asControlEvent()
            .subscribe { (x) in
                let nextVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "WalletName") as! WalletNameViewController
                nextVC.password = self.passwordTextField.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func validatePassword() {
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map { $0.vaildate() }
            .share(replay: 1)
        
        passwordValid
            .distinctUntilChanged()
            .subscribe(onNext: { (x) in
                x ? self.viewModel.statusText.onNext("Good😎") : self.viewModel.statusText.onNext("Weak🤔")
                self.statusLabel.textColor = x ? .blue : .red
                self.progressView.progress = x ? 1.0 : 0.3
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
