//
//  Created by Vonage on 21/10/26.
//

import Foundation
import Testing

@testable import VERASettings

@Suite("Captions translation preference")
@MainActor
struct CaptionsTranslationPreferenceTests {
    @Test("Preferences saved before the feature decode to the original language")
    func legacyPayloadDecodesToOriginal() throws {
        let legacy = try JSONEncoder().encode(PublisherSettingsPreferences.default)
        #expect(!String(decoding: legacy, as: UTF8.self).contains("captionsTranslationLanguage"))

        let decoded = try JSONDecoder().decode(PublisherSettingsPreferences.self, from: legacy)

        #expect(decoded.captionsTranslationLanguage == nil)
        #expect(decoded == .default)
    }

    @Test("A selected language round-trips and participates in equality")
    func selectedLanguageRoundTrips() throws {
        let preferences = PublisherSettingsPreferences(captionsTranslationLanguage: "es-ES")

        let decoded = try JSONDecoder().decode(
            PublisherSettingsPreferences.self, from: JSONEncoder().encode(preferences))

        #expect(decoded.captionsTranslationLanguage == "es-ES")
        #expect(decoded != .default)
    }

    @Test("The language list mirrors the 54 Web SDK codes without duplicates")
    func languageListMatchesWebSDK() {
        let codes = CaptionsTranslationLanguage.supportedCodes

        #expect(codes.count == 54)
        #expect(Set(codes).count == codes.count)
        #expect(Set(CaptionsTranslationLanguage.sortedCodes(locale: Locale(identifier: "en"))) == Set(codes))
        #expect(
            CaptionsTranslationLanguage.displayName(for: "es-ES", locale: Locale(identifier: "en")) == "Spanish (Spain)"
        )
    }

    @Test("The factory exposes captions availability, hidden by default")
    func factoryCaptionsAvailability() {
        let hidden = SettingsFactory(repository: MockSettingsRepository(), statsDataSource: MockStatsDataSource())
        let shown = SettingsFactory(
            repository: MockSettingsRepository(),
            statsDataSource: MockStatsDataSource(),
            isCaptionsTranslationAvailable: true
        )

        #expect(!hidden.isCaptionsTranslationAvailable)
        #expect(shown.isCaptionsTranslationAvailable)
    }
}
