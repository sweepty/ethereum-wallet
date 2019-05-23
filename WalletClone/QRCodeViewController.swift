//
//  QRCodeViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 23/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import PanModal
import RxSwift
import RxCocoa
import CoreImage
import Web3swift

class QRCodeViewController: UIViewController {
    
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var address = String()
    var ethAddress: EthereumAddress?
    
    private let alertViewHeight: CGFloat = 300
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        // 주소 쳌
        guard !address.isEmpty else {
            print("blabla")
            return
        }
        
        let checker = EthereumAddress(address)?.isValid ?? false
        
        // 주소 맞
        if checker {
            guard let qrImage = setupQRCode(address: address) else {
                return
            }
            self.addressLabel.text = address
            self.qrImageView.image = UIImage(ciImage: qrImage)
        }
        
        copyButton.rx.tap
            .subscribe { (_) in
                UIPasteboard.general.string = self.address
                // 알림알림
            }.disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe { (_) in
                self.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    
    func setupQRCode(address: String) -> CIImage? {
        let addressData = address.data(using: .ascii)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(addressData, forKey: "inputMessage")
        
        guard let qrImage = filter.outputImage else {
            return nil
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        return scaledQrImage
        
    }
}
