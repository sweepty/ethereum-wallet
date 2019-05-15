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
import RxDataSources
import Web3swift

class ViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var createWalletButton: UIButton!
    @IBOutlet weak var importWalletButton: UIButton!
    
    @IBOutlet weak var selectNetworkBarButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    
    var disposeBag = DisposeBag()
    let viewModel = ViewModel()
    
    var initialState: SectionedTableViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.walletList.share(replay: 1)
            .subscribe(onNext: { (sectionData) in
                self.initialState = SectionedTableViewState(sections: sectionData)
            }).disposed(by: disposeBag)
        
        setupUI()
        setupBind()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "My Wallet"
        self.tableView.rowHeight = 125
        
    }
    
    private func setupBind() {
        createWalletButton.rx.controlEvent(UIControlEvents.touchUpInside)
            .subscribe { (_) in
                let nextVC = UIStoryboard(name: "CreateWallet", bundle: nil).instantiateViewController(withIdentifier: "WalletRoot")
                self.present(nextVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        importWalletButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                let nextVC = UIStoryboard(name: "ImportWallet", bundle: nil).instantiateViewController(withIdentifier: "ImportRoot")
                self.present(nextVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        // RXDATASOURCES
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>(
            configureCell: { dataSource, tableView, indexPath, wallet in
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WalletTableViewCell
                
                cell.walletNameLabel?.text = wallet.name
                cell.addressLabel?.text = wallet.address
                cell.balanceLabel?.text = Ethereum.getBalance(walletAddress: wallet.address) ?? "err"
                return cell
                
        }, canEditRowAtIndexPath: { dataSource, indexPath in
            return true
        })
        
        selectNetworkBarButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Network") as! NetworkViewController
                nextVC.modalTransitionStyle = .crossDissolve
                nextVC.modalPresentationStyle = .overCurrentContext
                self.present(nextVC, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
//        // Add item
//        let addCommand = tableView.rx.tap.
//            .map(TableViewEditingCommand.AppendItem)
//        // Move item
//        let moveCommand = tableView.rx.itemDeleted
//            .map(TableViewEditingCommand.MoveItem)
        
        // Delete item
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableViewEditingCommand.DeleteItem)

        deleteCommand
            .observeOn(MainScheduler.asyncInstance)
            .scan(self.initialState) { (state, command) -> SectionedTableViewState in
                return (state?.execute(command: command))!
            }
            .startWith(initialState)
            .map {
                $0!.sections
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Wallet.self)
            .subscribe(onNext: { (wallet) in
                let inputPasswordAlert = UIAlertController(title: "지갑 비밀번호 입력", message: "지갑 비밀번호를 입력하세요.", preferredStyle: .alert)
                inputPasswordAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "Password"
                    textField.isSecureTextEntry = true
                })
                // 임시
                let wallet2 = Wallet(address: wallet.address, data: wallet.data, name: wallet.name, isHD: false, date: wallet.date)

                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    let checker = try? ETHWallet.extractPrivateKey(password: inputPasswordAlert.textFields?.first?.text ?? "", wallet: wallet2)
                    
                    if checker != nil {
                        let txVC = UIStoryboard(name: "Transaction", bundle: nil).instantiateViewController(withIdentifier: "SendTransaction") as! SendTransactionViewController
                        txVC.wallet = wallet2
                        txVC.password = (inputPasswordAlert.textFields?.first!.text)!
                        self.present(txVC, animated: true, completion: nil)
                        
                    } else {
                        let wrongAlert = UIAlertController(title: "잘못된 비번", message: nil, preferredStyle: .alert)
                        let onlyOK = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.present(inputPasswordAlert, animated: true, completion: nil)
                        })
                        wrongAlert.addAction(onlyOK)
                        
                        self.present(wrongAlert, animated: true)
                    }
                })
                
                let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
                
                // add actions
                inputPasswordAlert.addAction(cancel)
                inputPasswordAlert.addAction(okAction)
                
                self.present(inputPasswordAlert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
    }
}

enum TableViewEditingCommand {
    case AppendItem(item: Wallet, section: Int)
    case MoveItem(sourceIndex: IndexPath, destinationIndex: IndexPath)
    case DeleteItem(IndexPath)
}

struct SectionedTableViewState {
    fileprivate var sections: [SectionOfCustomData]
    
    init(sections: [SectionOfCustomData]) {
        self.sections = sections
    }
    
    func execute(command: TableViewEditingCommand) -> SectionedTableViewState {
        switch command {
        case .DeleteItem(let indexPath):
            var sections = self.sections
            var items = sections[indexPath.section].items
            
            // core data에서 삭제
            ETHWallet.deleteWallet(address: items[indexPath.row].address)
            items.remove(at: indexPath.row)
            
            sections[indexPath.section] = SectionOfCustomData(original: sections[indexPath.section], items: items)
            return SectionedTableViewState(sections: sections)
        default:
            return SectionedTableViewState(sections: self.sections)
        }
    }
}

