import AlphaWalletFoundation
// Copyright SIX DAY LLC. All rights reserved.
import Foundation

struct HelpUsViewModel {
    var title: String {
        return R.string.localizable.welldoneNavigationTitle()
    }

    var activityItems: [Any] {
        return [
            R.string.localizable.welldoneViewmodelSharingText(),
            URL(string: Constants.website)!,
        ]
    }
}
