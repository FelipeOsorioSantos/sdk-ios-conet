//
//  Conet.swift
//  conet_sdk
//
//  Created by Matheus Moraes Pinheiro on 03/10/24.
//
 
import Foundation
import JavaScriptCore
import WalletCore

public class ConetClass {
    public static let shared = ConetClass()
    private let vm = JSVirtualMachine()
    private let context: JSContext
    public init() {
        var jsCode = ""
        if let resourcePath = Bundle(for: type(of: self)).path(forResource: "Sentimentalist.bundle", ofType: "js") {
            print("Loading JS code")
            jsCode = try! String(contentsOf: URL(fileURLWithPath: resourcePath))
            print(jsCode)
        } else {
            print("Resource not found")
        }
        context = JSContext(virtualMachine: vm)
        
        context.exceptionHandler = { context, exception in
            print("JavaScript Error: \(String(describing: exception))")
        }
        
        context.evaluateScript("""
            if (typeof TextEncoder === 'undefined') {
                class TextEncoder {
                    encode(input = '') {
                        const utf8 = unescape(encodeURIComponent(input));
                        const arr = new Uint8Array(utf8.length);
                        for (let i = 0; i < utf8.length; i++) {
                            arr[i] = utf8.charCodeAt(i);
                        }
                        return arr;
                    }
                }

                this.TextEncoder = TextEncoder;
            }
            if (typeof TextEncoder === 'undefined') {
                class TextEncoder {
                    encode(input = '') {
                        const utf8 = unescape(encodeURIComponent(input));
                        const arr = new Uint8Array(utf8.length);
                        for (let i = 0; i < utf8.length; i++) {
                            arr[i] = utf8.charCodeAt(i);
                        }
                        return arr;
                    }
                }

                this.TextEncoder = TextEncoder;
            }
        if (typeof TextDecoder === 'undefined') {
                class TextDecoder {
                    decode(input = new Uint8Array()) {
                        let utf8 = '';
                        for (let i = 0; i < input.length; i++) {
                            utf8 += String.fromCharCode(input[i]);
                        }
                        return decodeURIComponent(escape(utf8));
                    }
                }

                global.TextDecoder = TextDecoder;
            }
        """)
        
        context.evaluateScript("var self = this;")
        
        // Avalia o código JavaScript que define as funções a serem usadas mais tarde.
        context.evaluateScript(jsCode)

        /*let jsCode = """
         function randomNumber(min, max) {
             min = Math.ceil(min);
             max = Math.floor(max);
             return Math.floor(Math.random() * (max - min + 1)) + min;
         }
         
         function analyze(sentence) {
             return randomNumber(-5, 5);
         }
         """*/
    
    }
    
    /*public func analyze(_ sentence: String) async -> Int {
        if let result = context.globalObject.invokeMethod("analyze", withArguments: [sentence]) {
            return Int(result.toInt32())
        }
        
        return 0
    }*/
    public func createTrustWallet() -> (privateKey: String?, ethereumAddress: String?, mnemonic: String?) {
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


    
    public func emoji(forScore score: Int) -> String {
        switch score {
        case 5...Int.max:
            return "😍"
        case 4:
            return "😃"
        case 3:
            return "😊"
        case 2, 1:
            return "🙂"
        case -1, -2:
            return "🙁"
        case -3:
            return "☹️"
        case -4:
            return "😤"
        case Int.min...(-5):
            return "😡"
        default:
            return "😐"
        }
    }
    
    public func greetUser(name: String) -> String {
        return "Hello, \(name)! Welcome to MySDK."
    }
    
    public func createWallet() -> String {
        
        return "0xxx01231231231sda"
    }
    
    public func startMining(wallet: String) -> Bool{
        print("Mining Starting")
        
        return false
    }
}
