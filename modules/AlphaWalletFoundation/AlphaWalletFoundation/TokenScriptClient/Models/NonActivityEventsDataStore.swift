// Copyright © 2020 Stormbird PTE. LTD.

import Combine
import Foundation
import RealmSwift

public protocol NonActivityEventsDataStore {
    func getLastMatchingEventSortedByBlockNumber(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String) -> EventInstanceValue?
    func addOrUpdate(events: [EventInstanceValue])
    func deleteEvents(for contract: AlphaWallet.Address)
    func getMatchingEvent(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String, filterName: String, filterValue: String) -> EventInstanceValue?
    func recentEventsChangeset(for contract: AlphaWallet.Address) -> AnyPublisher<ChangeSet<[EventInstanceValue]>, Never>
}

open class NonActivityMultiChainEventsDataStore: NonActivityEventsDataStore {
    private let store: RealmStore

    public init(store: RealmStore) {
        self.store = store
    }

    public func getMatchingEvent(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String, filterName: String, filterValue: String) -> EventInstanceValue? {
        let predicate = NonActivityMultiChainEventsDataStore
            .functional
            .matchingEventPredicate(for: contract, tokenContract: tokenContract, server: server, eventName: eventName, filterName: filterName, filterValue: filterValue)

        var event: EventInstanceValue?
        store.performSync { realm in
            event = realm.objects(EventInstance.self)
                .filter(predicate)
                .first
                .flatMap { EventInstanceValue(event: $0) }
        }
        return event
    }

    public func deleteEvents(for contract: AlphaWallet.Address) {
        store.performSync { realm in
            try? realm.safeWrite {
                let events = realm.objects(EventInstance.self)
                    .filter("tokenContract = '\(contract.eip55String)'")
                realm.delete(events)
            }
        }
    }

    public func recentEventsChangeset(for contract: AlphaWallet.Address) -> AnyPublisher<ChangeSet<[EventInstanceValue]>, Never> {
        var publisher: AnyPublisher<ChangeSet<[EventInstanceValue]>, Never>!
        store.performSync { realm in
            publisher = realm.objects(EventInstance.self)
                .filter("tokenContract = '\(contract.eip55String)'")
                .changesetPublisher
                .freeze()
                .receive(on: DispatchQueue.global())
                .map { change in
                    switch change {
                    case .initial(let eventActivities):
                        return .initial(Array(eventActivities.map { EventInstanceValue(event: $0) }))
                    case .update(let eventActivities, let deletions, let insertions, let modifications):
                        return .update(Array(eventActivities.map { EventInstanceValue(event: $0) }), deletions: deletions, insertions: insertions, modifications: modifications)
                    case .error(let error):
                        return .error(error)
                    }
                }
                .eraseToAnyPublisher()
        }

        return publisher
    }

    public func getLastMatchingEventSortedByBlockNumber(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String) -> EventInstanceValue? {
        let predicate = NonActivityMultiChainEventsDataStore
            .functional
            .matchingEventPredicate(for: contract, tokenContract: tokenContract, server: server, eventName: eventName)

        var event: EventInstanceValue?
        store.performSync { realm in
            event = realm.objects(EventInstance.self)
                .filter(predicate)
                .sorted(byKeyPath: "blockNumber")
                .last
                .flatMap { EventInstanceValue(event: $0) }
        }

        return event
    }

    public func addOrUpdate(events: [EventInstanceValue]) {
        guard !events.isEmpty else { return }
        let eventsToSave = events.map { EventInstance(event: $0) }

        store.performSync { realm in
            try? realm.safeWrite {
                realm.add(eventsToSave, update: .all)
            }
        }
    }
}

extension NonActivityMultiChainEventsDataStore {
    enum functional {}
}

extension NonActivityMultiChainEventsDataStore.functional {

    static func isFilterMatchPredicate(filterName: String, filterValue: String) -> NSPredicate {
        return NSPredicate(format: "filter = '\(filterName)=\(filterValue)'")
    }

    static func matchingEventPredicate(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String, filterName: String, filterValue: String) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [
            EventsActivityDataStore.functional.isContractMatchPredicate(contract: contract),
            EventsActivityDataStore.functional.isChainIdMatchPredicate(server: server),
            EventsActivityDataStore.functional.isTokenContractMatchPredicate(contract: tokenContract),
            EventsActivityDataStore.functional.isEventNameMatchPredicate(eventName: eventName),
            isFilterMatchPredicate(filterName: filterName, filterValue: filterValue),
        ])
    }

    static func matchingEventPredicate(for contract: AlphaWallet.Address, tokenContract: AlphaWallet.Address, server: RPCServer, eventName: String) -> NSPredicate {
        EventsActivityDataStore.functional.matchingEventPredicate(for: contract, tokenContract: tokenContract, server: server, eventName: eventName)
    }
}
