//
//  NetworkViewController.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 10/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NetworkViewController: UIViewController {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var backImageView: UIImageView!
    
    let disposeBag = DisposeBag()
    
    var snapShotImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImageView.image = snapShotImage
        
        dismissButton.rx.tap.asControlEvent()
            .subscribe(onNext: { (_) in
                self.dismiss(animated: false, completion: nil)
            }).disposed(by: disposeBag)
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
