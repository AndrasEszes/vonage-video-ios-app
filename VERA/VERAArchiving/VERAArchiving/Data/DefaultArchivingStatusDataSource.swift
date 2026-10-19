//
//  Created by Vonage on 20/1/26.
//

import Combine
import Foundation
import VERADomain

public final class DefaultArchivingStatusDataSource: ArchivingStatusDataSource {
    private let _archivingState = CurrentValueRelay<ArchivingState, Never>(.idle)
    public var archivingState: AnyPublisher<ArchivingState, Never> {
        _archivingState.publisher
    }

    public init() {
    }

    public func set(archivingState: ArchivingState) {
        _archivingState.send(archivingState)
    }

    public func reset() {
        _archivingState.send(.idle)
    }
}
