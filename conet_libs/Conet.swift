import Foundation
import WalletCore
import CryptoKit

public class ConetClass {
    private let userDefaultsKey = "userWallet"

    public init() {}

    public func createWallet(passphrase: String = "", name: String = "", email: String = "") -> (privateKey: String?, ethereumAddress: String?, mnemonic: String?, profile: Profile?) {
        if let existingWallet = loadWallet() {
            
            return existingWallet
        }

        
        let wallet = HDWallet(strength: 128, passphrase: passphrase)
        
        let ethereumAddress = wallet?.getAddressForCoin(coin: .ethereum).description
        let mnemonic = wallet?.mnemonic
        let privateKeyData = wallet?.getKeyForCoin(coin: .ethereum)
        let privateKey = privateKeyData?.data.hexString

       
        let keyPair = createKeyPair(passphrase: passphrase)
        let publicKey = keyPair?.publicKey ?? ""
        let privateKeyArmor = keyPair?.encryptedPrivateKey ?? ""

        // Cria o perfil
        let profile = Profile(
            tokens: nil,
            publicKeyArmor: ethereumAddress ?? "",
            keyID: ethereumAddress ?? "",
            isPrimary: true,
            referrer: nil,
            isNode: false,
            pgpKey: PGPKey(publicKey: publicKey, privateKey: privateKeyArmor),
            privateKeyArmor: privateKey ?? "",
            hdPath: "",
            index: 0
        )

        
        saveWallet(privateKey: privateKey, ethereumAddress: ethereumAddress, mnemonic: mnemonic, profile: profile)

        return (privateKey, ethereumAddress, mnemonic, profile)
    }

    public func createKeyPair(passphrase: String) -> (publicKey: String, encryptedPrivateKey: String)? {
        let privateKey = Curve25519.KeyAgreement.PrivateKey()
        let publicKey = privateKey.publicKey

        // Converter as chaves para formato base64
        let publicKeyData = publicKey.rawRepresentation.base64EncodedString()
        
        // Criptografar a chave privada usando a passphrase
        guard let encryptedPrivateKey = encryptPrivateKey(privateKeyData: privateKey.rawRepresentation.base64EncodedString(), passphrase: passphrase) else {
            return nil
        }
        print("publicKeyData", publicKeyData)
        print("privateKeyData", encryptedPrivateKey)
        return (publicKeyData, encryptedPrivateKey)
    }

    private func encryptPrivateKey(privateKeyData: String, passphrase: String) -> String? {
        // Convertendo a passphrase em dados
        guard let keyData = passphrase.data(using: .utf8) else { return nil }
        
        // Gerar uma chave simétrica a partir da passphrase
        let symmetricKey = SymmetricKey(size: .bits256)
        
        // Encrypting using AES-GCM
        let nonce = AES.GCM.Nonce()
        
        do {
            let sealedBox = try AES.GCM.seal(keyData, using: symmetricKey, nonce: nonce)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Error encrypting private key: \(error)")
            return nil
        }
    }
    public func loadWallet() -> (privateKey: String?, ethereumAddress: String?, mnemonic: String?, profile: Profile?)? {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: userDefaultsKey) {
            if let wallet = try? JSONDecoder().decode(Wallet.self, from: data) {
                return (wallet.privateKey, wallet.ethereumAddress, wallet.mnemonic, wallet.profile)
            }
        }
        return nil
    }

    public func clearWallet() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: userDefaultsKey)
    }

    public func saveWallet(privateKey: String?, ethereumAddress: String?, mnemonic: String?, profile: Profile?) {
        guard let privateKey = privateKey,
              let ethereumAddress = ethereumAddress,
              let mnemonic = mnemonic,
              let profile = profile else {
            print("Wallet data is nil, not saving.")
            return
        }

        let wallet = Wallet(privateKey: privateKey, ethereumAddress: ethereumAddress, mnemonic: mnemonic, profile: profile)
        if let encoded = try? JSONEncoder().encode(wallet) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: userDefaultsKey)
            print("Wallet saved to UserDefaults.") 
        } else {
            print("Failed to encode wallet data.")
        }
    }
}

public struct Wallet: Codable {
    let privateKey: String
    let ethereumAddress: String
    let mnemonic: String
    let profile: Profile
}

public struct Profile: Codable {
    public let tokens: String?
    public let publicKeyArmor: String
    public let keyID: String
    public let isPrimary: Bool
    public let referrer: String?
    public let isNode: Bool
    public let pgpKey: PGPKey
    public let privateKeyArmor: String
    public let hdPath: String
    public let index: Int

    public init(tokens: String?, publicKeyArmor: String, keyID: String, isPrimary: Bool, referrer: String?, isNode: Bool, pgpKey: PGPKey, privateKeyArmor: String, hdPath: String, index: Int) {
        self.tokens = tokens
        self.publicKeyArmor = publicKeyArmor
        self.keyID = keyID
        self.isPrimary = isPrimary
        self.referrer = referrer
        self.isNode = isNode
        self.pgpKey = pgpKey
        self.privateKeyArmor = privateKeyArmor
        self.hdPath = hdPath
        self.index = index
    }
}

public struct PGPKey: Codable {
    public let publicKey: String
    public let privateKey: String

    public init(publicKey: String, privateKey: String) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}
