## Installation

### Swift Package Manager

Use Xcode to add to the project (**File -> Add Package Dependencies**)

## Usage

### Getting Started

createWallet -> create or recover a storaged wallet at userDefaults

```swift
import conet_libs
    private func loadWallet() {
        let conet = ConetClass()
        let wallet = conet.createWallet()
        self.walletInfo = wallet
    }
```

clearWallet -> clear a storaged wallet

```swift
    private func clearWallet() {
        let conet = ConetClass()
        conet.clearWallet()
        walletInfo = (nil, nil, nil, nil)
    }
```

userDefaults: 

```swift
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
``
