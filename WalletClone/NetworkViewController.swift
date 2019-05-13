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
    
    @IBOutlet weak var networkView: UIView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // https://stackoverflow.com/a/48661043
        networkView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        up()
    }
    
    @objc func dismissView(_ sender: UIPanGestureRecognizer) {
        let percentThreshold: CGFloat = 0.3
        let translation = sender.translation(in: networkView)
        
        let newY = ensureRange(value: networkView.frame.minY + translation.y, minimum: 0, maximum: networkView.frame.maxY)
        let progress = progressAlongYxis(newY, networkView.bounds.height)
        
        if newY >= networkView.frame.origin.y {
            networkView.frame.origin.y = newY
        }
        
        if sender.state == .recognized {
            let velocity = sender.velocity(in: networkView)
            if velocity.y >= 300 || progress > percentThreshold {
                self.dismiss(animated: true)
            }
        }
        
        sender.setTranslation(.zero, in: networkView)
    }
    
    func progressAlongYxis(_ pointOnYxis: CGFloat, _ yxisLength: CGFloat) -> CGFloat {
        let point = pointOnYxis - yxisLength
        if point < 0.0 { return 0.0 }
        let movementOnYxis = point / yxisLength
        let positiveMovementOnYxis = fmaxf(Float(movementOnYxis), 0.0)
        let positiveMovementOnYxisPercent = fminf(positiveMovementOnYxis, 1.0)
        return CGFloat(positiveMovementOnYxisPercent)
    }
    
    func ensureRange<T>(value: T, minimum: T, maximum: T) -> T where T : Comparable {
        return min(max(value, minimum), maximum)
    }
    
    private func up() {
        self.viewTopConstraint.constant -= self.networkView.frame.size.height
        self.viewBottomConstraint.constant -= self.networkView.frame.size.height
        
        UIView.animate(withDuration: 0.7, delay: 0.2, options: .curveEaseOut, animations: {
            self.networkView.layoutIfNeeded()
            
        })
    }
    
    private func setupUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.networkView.layer.cornerRadius = 15
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
