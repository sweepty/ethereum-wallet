//
//  WalletLastViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 08/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Web3swift

class WalletLastViewController: UIViewController {

    @IBOutlet weak var privateKeyTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    var password: String?
    
    var wallet: Wallet?
    
    var disposeBag = DisposeBag()
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        setupBind()
    }
    
    private func setupUI() {
        self.privateKeyTextField.isUserInteractionEnabled = false
    }
    
    private func setupBind() {
        self.viewModel.walletList.onNext(ETHWallet.selectAllWallet())
        
        viewModel.walletList
            .subscribe(onNext: { (wallet) in
                print("새로운 지갑 생성됨 \(wallet)")
            }).disposed(by: disposeBag)
        
        // 완료
        doneButton.rx.controlEvent(.touchUpInside)
            .subscribe { (x) in
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                self.dismiss(animated: false, completion: nil)
                
            }.disposed(by: disposeBag)

        extractPk()
            .bind(to: privateKeyTextField.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    private func extractPk() -> Observable<String> {
        guard let wallet = self.wallet else {
            return Observable.just("지값 없음")
        }
        
        guard let pwd = password else {
            return Observable.just("비번 없음")
        }
        
        let pk = ETHWallet.extractPrivateKey(password: pwd, wallet: wallet)
        return Observable.just(pk)
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
