//
//  Created by Vonage on 20/1/26.
//

import Combine
import Foundation
import VERAArchiving
import VERADomain

public final class ArchivingStatusDataSourceSpy: ArchivingStatusDataSource {
    public let _archivingState = CurrentValueRelay<ArchivingState, Never>(.idle)
    private let calls = Calls()

    public var archivingState: AnyPublisher<ArchivingState, Never> {
        calls.withLock { $0.archivingStatusCallCount += 1 }
        return _archivingState.publisher
    }
    public var archivingStatusCallCount: Int { calls.withLock { $0.archivingStatusCallCount } }
    public var setCallCount: Int { calls.withLock { $0.setCallCount } }
    public var resetCallCount: Int { calls.withLock { $0.resetCallCount } }
    public var lastArchivingStatus: ArchivingState? { calls.withLock { $0.lastArchivingStatus } }

    public init() {}

    public func set(archivingState: ArchivingState) {
        calls.withLock {
            $0.setCallCount += 1
            $0.lastArchivingStatus = archivingState
        }
        _archivingState.send(archivingState)
    }

    public func reset() {
        calls.withLock { $0.resetCallCount += 1 }
        _archivingState.send(.idle)
    }

    /// The lock protects test call recordings; no publisher callbacks run under it.
    private final class Calls: @unchecked Sendable {
        struct Values {
            var archivingStatusCallCount = 0
            var setCallCount = 0
            var resetCallCount = 0
            var lastArchivingStatus: ArchivingState?
        }
        private let lock = NSLock()
        private var values = Values()
        func withLock<Result>(_ operation: (inout Values) -> Result) -> Result {
            lock.withLock { operation(&values) }
        }
    }
}
