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
import RxDataSources
import secp256k1_swift
import BigInt

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
    
    // Import account with private key
    public static func importWallet(privateKey: String, password: String, name: String) -> Wallet {
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
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
                                       isHD: false,
                                       date: data.value(forKey: "date") as! Date)
                walletList.append(newWallet)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return walletList
    }
    
    public static func deleteWallet(address: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Wallets")
        fetchRequest.predicate = NSPredicate(format: "address == %@", address)
        
        let fetch = try! managedContext.fetch(fetchRequest)
        let objectToDelete = fetch[0]
        managedContext.delete(objectToDelete)
        
        do {
            try managedContext.save()
        } catch {
            print("ERROR \(error)")
        }
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
    
    // extract privatekey using password - THIS IS A UNSAFE FUNCTION
    public static func extractPrivateKey(password: String, wallet: Wallet) throws -> String {
        let ethereumAddress = EthereumAddress(wallet.address)!
        let keystoreManager = generateKeystoreManager(wallet: wallet)
        
        guard let pkData = try? keystoreManager.UNSAFE_getPrivateKeyData(password: password, account: ethereumAddress).toHexString() else {
            throw AbstractKeystoreError.invalidPasswordError
        }
        return pkData
    }
    
    /// Create transaction and send that.
    public static func sendTransaction(value: String,
                                               fromAddressString: String,
                                               toAddressString: String,
                                               gasPricePolicy: TransactionOptions.GasPricePolicy,
                                               gasLimitPolicy: TransactionOptions.GasLimitPolicy,
                                               password: String,
                                               wallet: Wallet,
                                               completion: @escaping(_: Result<TransactionSendingResult, Error>) -> Void) {
        
        let walletAddress = EthereumAddress(fromAddressString)!
        let toAddress = EthereumAddress(toAddressString)!
        let provider = Ethereum.endpointProvider
        
        let keystore = self.generateKeystoreManager(wallet: wallet)
        provider.addKeystoreManager(keystore)
        
        let contract = provider.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
        let amount = Web3.Utils.parseToBigUInt(value, units: .eth)
        
        var options = TransactionOptions.defaultOptions
        options.value = amount
        options.from = walletAddress
        options.gasPrice = gasPricePolicy
        options.gasLimit = gasLimitPolicy
        
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: Data(),
            transactionOptions: options)!
        
        do {
            let result = try tx.send(password: password)
            completion(.success(result))
            return
        } catch {
            completion(.failure(error))
            return
        }
    }
}

// RXDATASOURCES
struct SectionOfCustomData {
    var items: [Wallet]
}

extension SectionOfCustomData: SectionModelType {
    init(original: SectionOfCustomData, items: [Wallet]) {
        self = original
        self.items = items
    }
}
