//
//  WalletNameViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 08/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Web3swift

class WalletNameViewController: UIViewController {

    @IBOutlet weak var walletNameTextField: UITextField!
    
    var disposeBag = DisposeBag()
    
    let viewModel = ViewModel()
    
    var password = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBind()
    }
    
    private func setupBind() {
        // setup next barbuttonitem
        let nextBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = nextBtn
        
        nextBtn.rx.tap.asControlEvent()
            .subscribe { (x) in
                // 지갑생성
                let wallet = ETHWallet.createAccount(password: self.password, name: self.walletNameTextField.text!)
                
                // 생성한 지갑 coredata에 넣기
                ETHWallet.insertWallet(wallet: wallet)
                
                // viewmodel에 넣어줌
//                self.viewModel.walletList.onNext(ETHWallet.selectAllWallet())
                
                // 다음 뷰로 넘어갑니다
                let lastVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "Done") as! WalletLastViewController
                lastVC.wallet = wallet
                lastVC.password = self.password
//                self.present(lastVC, animated: true, completion: nil)
                self.navigationController?.pushViewController(lastVC, animated: true)
                
            }.disposed(by: disposeBag)
        
        walletNameTextField.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: nextBtn.rx.isEnabled )
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
