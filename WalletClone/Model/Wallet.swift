//
//  Wallet.swift
//  WalletClone
//
//  Created by Seungyeon Lee on 03/05/2019.
//  Copyright © 2019 Seungyeon Lee. All rights reserved.
//

import Foundation
import Web3swift
import CoreData

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
    let date: Date
}

class ETHWallet {
    
    // 지갑 주소 생성
    public static func createAccount(password: String, name: String) -> Wallet {
        let keystore = try! EthereumKeystoreV3(password: password)!
        let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
        let address = keystore.addresses!.first!.address
        let wallet = Wallet(address: address, data: keyData, name: name, isHD: false, date: Date())
        return wallet
    }
    
    // Insert wallet info to coredata
    public static func insertWallet(wallet: Wallet) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Wallets", in: context)
        let newWallet = NSManagedObject(entity: entity!, insertInto: context)
        newWallet.setValuesForKeys(["id": 0, "address": wallet.address, "data": wallet.data, "date": wallet.date, "name": wallet.name])
        do {
            try context.save()
        } catch let error as NSError {
            print("WARNING!!! Failed saving \(error)")
        }
    }
    public static func selectAllWallet() -> [Wallet] {
        var walletObjects = [NSManagedObject]()
        var walletList = [Wallet]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return walletList
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Wallets")
        
        do {
            walletObjects = try managedContext.fetch(fetchRequest)
            
            for data in walletObjects {
                let newWallet = Wallet(address: data.value(forKey: "address") as! String,
                                       data: data.value(forKey: "data") as! Data,
                                       name: data.value(forKey: "name") as! String,
                                       isHD: true,
                                       date: data.value(forKey: "date") as! Date)
                walletList.append(newWallet)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return walletList
    }
    
    // Get Keystore Manager from wallet data
    public static func generateKeystoreManager(wallet: Wallet) -> KeystoreManager {
        let data = wallet.data
        let keystoreManager: KeystoreManager
        
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        
        return keystoreManager
    }
    
    // extract privatekey - THIS IS A UNSAFE FUNCTION
    public static func extractPrivateKey(password: String, wallet: Wallet) -> String {
        let ethereumAddress = EthereumAddress(wallet.address)!
        let keystoreManager = generateKeystoreManager(wallet: wallet)
        let pkData = try! keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString()
        
        return pkData
    }
}
