//
//  Task.swift
//  AlphaWalletFoundation
//
//  Created by Vladyslav Shepitko on 21.03.2023.
//

import Combine
import Foundation

extension Task {
    public func store(in cancellables: inout Set<AnyCancellable>) {
        asCancellable().store(in: &cancellables)
    }

    func asCancellable() -> AnyCancellable {
        .init { self.cancel() }
    }
}
