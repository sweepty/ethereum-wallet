//
//  ViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 02/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        setupUI()
        setupBind()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "My Wallet"
    }
    
    private func setupBind() {
        createWalletButton.rx.controlEvent(UIControlEvents.touchUpInside)
            .subscribe { (_) in
                let nextVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "WalletRoot")
                self.present(nextVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        viewModel.walletList
            .bind(to: self.tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, wallet, cell in
                cell.textLabel?.text = wallet.name
                cell.detailTextLabel?.text = wallet.address
        }.disposed(by: disposeBag)
        
    }
    
}

