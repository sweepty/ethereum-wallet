//
//  ImportPKViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 13/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import secp256k1_swift

class ImportPKViewController: UIViewController {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!
    
    @IBOutlet weak var privateKeyTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextBarButton.isEnabled = false
        
        setupBind()
    }
    
    private func setupBind() {
        let validatePK = privateKeyTextField.rx.text.orEmpty
            .map { SECP256K1.verifyPrivateKey(privateKey: Data(hex: $0)) }
            .share(replay: 1)
        
        validatePK
            .bind(to: nextBarButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        cancelBarButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        nextBarButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                let nextVC = UIStoryboard(name: "ImportWallet", bundle: nil).instantiateViewController(withIdentifier: "ImportPasswordName") as! ImportNameViewController
                nextVC.privateKey = self.privateKeyTextField.text!
                self.navigationController?.pushViewController(nextVC, animated: true)
        }.disposed(by: disposeBag)

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
