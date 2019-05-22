//
//  TxResultViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 15/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Web3swift

class TxResultViewController: UIViewController {
    
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    var txResult: TransactionSendingResult?
    
    let viewModel = TransactionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.hashLabel.text = txResult?.hash
        
        doneButton.rx.controlEvent(.touchUpInside)
            .subscribe { (_) in
                self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
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
