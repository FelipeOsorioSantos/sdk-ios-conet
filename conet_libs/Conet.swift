import Foundation
import WalletCore
import CryptoKit
import ObjectivePGP

struct NodeInfo {
    let ipAddress: String
    let regionName: String
    let pgp: String
}

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
    
    private func loadPGPKeys(armoredKey: String) throws -> [Key] {
        print("armoredKey:", armoredKey)
        let data = armoredKey.data(using: .utf8)!
        
        let keys = try ObjectivePGP.readKeys(from: data)
        
        guard !keys.isEmpty else {
            throw NSError(domain: "PGPError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read PGP keys"])
        }
        
        print("pgpKeys:", keys.count)
        print("pgpKeys1:", keys[0].publicKey?.subKeys[0])
        return keys // Retorna todas as chaves
    }
    

    
    public func startMining() {
        let nodes = ["KS.US","LND.GB","ND.US","MD.ES","NJ.US","NW.DE","PA.US"]
        let nodeInfo = NodeInfo(
            ipAddress: "216.225.197.187",
            regionName: "PA.US",
            pgp: """
            LS0tLS1CRUdJTiBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tCgp4ak1FWm43eE5CWUpLd1lCQkFIYVJ3OEJBUWRBZXRFMnRXVVpZZ3NBcmpnUmh1NEdrS2xnSk5UVUk1THIKUWFkcjVIRzhXSFROS2pCNE5USTFPRGt4TW1RMlJqSTRORFU1TWpFek16TmtNVGcwTkRJNE5rUkNPR0l5Ck0yRTFZVVpoWk1LTUJCQVdDZ0ErQllKbWZ2RTBCQXNKQndnSmtDbG13ZEMyNUpZM0F4VUlDZ1FXQUFJQgpBaGtCQXBzREFoNEJGaUVFT1pNWnVVQnpIZnBiNnlTWUtXYkIwTGJrbGpjQUFNWGtBUDk4RGxNampxcnoKVGtRNjkvc1Rka29VL3BZa1N1c29QZVQxUDliVWRZS1BtUUVBOEhxNmZScTA4SmNhKzByT1NUQ2FReDVpClhWTU1xeTJlR2tHVmdYcUZQQWpPT0FSbWZ2RTBFZ29yQmdFRUFaZFZBUVVCQVFkQXE1UFUxaXVnMUQ2NQo1UjREMHNaTjMzMDY3YnVqdFVMZjN5UmdRL2hXb3hjREFRZ0h3bmdFR0JZS0FDb0ZnbVorOFRRSmtDbG0Kd2RDMjVKWTNBcHNNRmlFRU9aTVp1VUJ6SGZwYjZ5U1lLV2JCMExia2xqY0FBRlhkQVA5azFGL3c1cWlrCmlkT0ZoTXJ3UVRxUlVZY3c5emV1M3E4U0QwR3ozcmpoeEFFQXRNZXpmanEwVFJSY0FSdTIzbGt1dkwyMgp0NVZFZjRjSkdCUDlsZ2svTnc0PQo9N1lJbgotLS0tLUVORCBQR1AgUFVCTElDIEtFWSBCTE9DSy0tLS0tCg==
            """
        )
        
        print(nodeInfo)
        let base64EncodedPGP = nodeInfo.pgp
        var pgpString: String? = nil
        var pgpKeys: [Key]? = nil
        if let decodedData = Data(base64Encoded: base64EncodedPGP) {
            if let decodedString = String(data: decodedData, encoding: .utf8) {
                pgpString = decodedString
                print("Chave PGP armored: \(pgpString!)")
            } else {
                print("Erro ao converter dados para string")
            }
        } else {
            print("Erro ao decodificar Base64")
        }

        do {
            if let pgpString = pgpString {
                pgpKeys = try loadPGPKeys(armoredKey: pgpString)
            } else {
                print("pgpString é nulo, não é possível carregar a chave PGP")
            }
        } catch {
            print("Erro ao carregar a chave PGP: \(error)")
        }
        if let publicKey = pgpKeys![0].publicKey?.subKeys[0] {
            let keyID = publicKey.keyID
            let hexString = keyID.description.uppercased()
            let domain = hexString + ".conet.network"
                print("Domain: \(domain)")
            } else {
                print("Error")
            }
        
    }}

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
