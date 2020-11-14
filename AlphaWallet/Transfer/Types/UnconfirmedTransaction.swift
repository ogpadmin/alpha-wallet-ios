// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct UnconfirmedTransaction {
    let transferType: TransferType
    let value: BigInt
    let recipient: AlphaWallet.Address?
    let contract: AlphaWallet.Address?
    let data: Data?
    let gasLimit: BigInt?
    let tokenId: BigUInt?
    let gasPrice: BigInt?
    let nonce: BigInt?
    // these are not the v, r, s value of a signed transaction
    // but are the v, r, s value of a signed ERC875 order
    // TODO: encapsulate it in the data field
    //TODO who uses this?
    let v: UInt8?
    let r: String?
    let s: String?
    let expiry: BigUInt?
    let indices: [UInt16]?

    init(
        transferType: TransferType,
        value: BigInt,
        recipient: AlphaWallet.Address?,
        contract: AlphaWallet.Address?,
        data: Data?,
        tokenId: BigUInt? = nil,
        indices: [UInt16]? = nil,
        gasLimit: BigInt? = nil,
        gasPrice: BigInt? = nil,
        nonce: BigInt? = nil
    ) {
        self.transferType = transferType
        self.value = value
        self.recipient = recipient
        self.contract = contract
        self.data = data
        self.tokenId = tokenId
        self.indices = indices
        self.gasLimit = gasLimit
        self.gasPrice = gasPrice
        self.nonce = nonce
        self.v = nil
        self.r = nil
        self.s = nil
        self.expiry = nil
    }
}
