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

    @IBOutlet weak var txTestLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    var txResult: TransactionSendingResult?
    
    let viewModel = TransactionViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        let resultOb = viewModel.result.share(replay: 1)
        
        resultOb
            .map { $0.transaction.txhash }
            .bind(to: txTestLabel.rx.text)
            .disposed(by: disposeBag)
        
        resultOb
            .map { $0.hash }
            .bind(to: hashLabel.rx.text)
            .disposed(by: disposeBag)
        
        doneButton.rx.controlEvent(.touchUpInside)
            .subscribe { (_) in
                self.dismiss(animated: true, completion: nil)
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
