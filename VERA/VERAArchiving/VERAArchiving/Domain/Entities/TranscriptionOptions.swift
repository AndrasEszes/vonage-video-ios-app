//
//  Created by Vonage on 26/10/26.
//

import Foundation

/// Language spoken in the meeting, used by the backend to transcribe it.
///
/// The raw values are the BCP-47 codes sent as `primaryLanguageCode`.
public enum TranscriptionLanguage: String, CaseIterable, Identifiable, Sendable {
    case englishUS = "en-US"
    case spanish = "es-ES"
    case german = "de-DE"
    case italian = "it-IT"
    case japanese = "ja-JP"

    public var id: String { rawValue }

    /// The BCP-47 code sent to the backend.
    public var code: String { rawValue }
}

/// Options chosen by the user when starting a post-call transcription.
///
/// They apply to a single transcription archive and cannot change while it runs.
public struct TranscriptionOptions: Equatable, Sendable {
    /// Whether the transcript includes an AI-generated summary.
    public var hasSummary: Bool
    /// The language spoken in the meeting.
    public var language: TranscriptionLanguage

    public init(hasSummary: Bool, language: TranscriptionLanguage) {
        self.hasSummary = hasSummary
        self.language = language
    }

    /// Summary on, English (US).
    public static let `default` = TranscriptionOptions(hasSummary: true, language: .englishUS)
}
