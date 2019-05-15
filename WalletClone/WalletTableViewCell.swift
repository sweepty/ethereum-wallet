//
//  WalletTableViewCell.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 09/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        copyAddressButton.rx.tap.asControlEvent()
            .subscribe { (_) in
                UIPasteboard.general.string = self.addressLabel.text
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
