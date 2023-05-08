// Copyright © 2019 Stormbird PTE. LTD.

import AlphaWalletFoundation
import Foundation
import UIKit

struct PromptBackupWalletAfterWalletCreationViewViewModel: PromptBackupWalletViewModel {
    let walletAddress: AlphaWallet.Address

    var backgroundColor: UIColor {
        return Configuration.Color.Semantic.promptBackupWalletAfterWalletCreationViewBackground
    }

    var title: String {
        return R.string.localizable.backupPromptTitle()
    }

    var description: String {
        return R.string.localizable.backupPromptDescriptionWithoutAmount()
    }

    var backupButtonBackgroundColor: UIColor {
        return Configuration.Color.Semantic.promptBackupWalletAfterWalletCreationViewBackupButtonBackground
    }
}
