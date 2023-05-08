// Copyright © 2018 Stormbird PTE. LTD.

import Combine
import Foundation

public class IsErc875Contract {
    private let blockchainProvider: BlockchainProvider

    public init(blockchainProvider: BlockchainProvider) {
        self.blockchainProvider = blockchainProvider
    }

    public func getIsERC875Contract(for contract: AlphaWallet.Address) -> AnyPublisher<Bool, SessionTaskError> {
        blockchainProvider
            .call(Erc875IsStormBirdContractMethodCall(contract: contract))
    }
}
