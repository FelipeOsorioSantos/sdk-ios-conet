//
//  Conet.swift
//  conet_sdk
//
//  Created by Stage Consulting on 03/10/24.
//
 
import Foundation
import WalletCore

public class ConetClass {

    public init() {}
    
    public func createWallet() -> (privateKey: String?, ethereumAddress: String?, mnemonic: String?) {
        // Generate a new 12-word mnemonic
        let wallet = HDWallet(strength: 128, passphrase: "")
        
        // Get Ethereum address
        let ethereumAddress = wallet?.getAddressForCoin(coin: .ethereum).description
        
        // Get the mnemonic phrase for recovering the wallet
        let mnemonic = wallet?.mnemonic
        
        // Get the private key
        let privateKeyData = wallet?.getKeyForCoin(coin: .ethereum)
        let privateKey = privateKeyData?.data.hexString // Convert Data to Hex String
        
        // Print results
        print("Private Key: \(privateKey ?? "N/A")")
        print("New Ethereum Address: \(ethereumAddress ?? "N/A")")
        print("Mnemonic for wallet recovery: \(mnemonic ?? "N/A")")
        
        return (privateKey, ethereumAddress, mnemonic)
    }

}
