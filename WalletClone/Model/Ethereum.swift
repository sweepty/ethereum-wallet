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
    static var endpointProvider: web3 {
//        let userdefaultsNetwork = UserDefaults.standard.integer(forKey: "network")
        // 임시
        let userdefaultsNetwork: Int = 0

        switch userdefaultsNetwork {
        case 0:
            return Web3.InfuraMainnetWeb3()
        default:
            return Web3.InfuraRopstenWeb3()
        }
    }
    
    // get balance
    static func getBalance(walletAddress: String) -> String? {
        let ethAddress = EthereumAddress(walletAddress)!
        let balanceResult = try! endpointProvider.eth.getBalance(address: ethAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 3)!
        
        return balanceString
    }
}
