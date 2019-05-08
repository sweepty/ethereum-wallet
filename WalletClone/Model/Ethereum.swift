//
//  Ethereum.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 08/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import Web3swift
import BigInt

struct Ethereum {
    // Ropsten Infura Endpoint Provider
    let web3 = Web3.InfuraMainnetWeb3()
    
//    static var endpointProvider: web3 {
//        let userdefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
//
//        switch userdefaultsNetwork {
//        case 0:
//            return Web3.InfuraMainnetWeb3()
//        default:
//            return Web3.InfuraRopstenWeb3()
//        }
//    }
    
    // get balance
    func getBalance(walletAddress: EthereumAddress) -> String? {
        let balanceResult = try! web3.eth.getBalance(address: walletAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
        
        return balanceString
    }
}
