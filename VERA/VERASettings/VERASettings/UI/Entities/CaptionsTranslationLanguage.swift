//
//  Created by Vonage on 21/10/26.
//

import Foundation

/// Languages remote captions can be translated into.
///
/// The iOS SDK takes a plain BCP-47 string and exposes no list, so this mirrors the Web SDK
/// `CaptionsLanguageCode` union (`@vonage/client-sdk-video` 2.35.1) to keep Web and iOS VERA identical.
public enum CaptionsTranslationLanguage {
    public static let supportedCodes: [String] = [
        "af-ZA", "ar-AE", "ar-SA", "eu-ES", "ca-ES", "zh-HK", "zh-CN", "zh-TW", "hr-HR", "cs-CZ",
        "da-DK", "nl-NL", "en-AU", "en-GB", "en-IN", "en-IE", "en-NZ", "en-AB", "en-ZA", "en-US",
        "en-WL", "fa-IR", "fi-FI", "fr-FR", "fr-CA", "gl-ES", "de-DE", "de-CH", "el-GR", "he-IL",
        "hi-IN", "id-ID", "it-IT", "ja-JP", "ko-KR", "lv-LV", "ms-MY", "no-NO", "pl-PL", "pt-PT",
        "pt-BR", "ro-RO", "ru-RU", "sr-RS", "sk-SK", "so-SO", "es-ES", "es-US", "sv-SE", "tl-PH",
        "th-TH", "uk-UA", "vi-VN", "zu-ZA",
    ]

    /// Scottish and Welsh English use non-standard codes that ICU cannot name, so they come from the
    /// module's string catalog (in the current UI language) instead of `Locale`.
    private static let dialectNames = [
        "en-AB": "English (Scotland)",
        "en-WL": "English (Wales)",
    ]

    /// Localized language name with its first letter capitalized (native equivalent of Web
    /// `Intl.DisplayNames`), falling back to the code. ICU returns lowercase names in some
    /// languages, e.g. "español (España)".
    public static func displayName(for code: String, locale: Locale = .current) -> String {
        let name = dialectNames[code]?.localized ?? locale.localizedString(forIdentifier: code) ?? code
        return name.prefix(1).uppercased(with: locale) + name.dropFirst()
    }

    /// A picker row: a supported code and its localized name.
    struct Option: Equatable {
        let code: String
        let name: String
    }

    /// Supported languages ordered by their localized name so the picker is easy to scan.
    ///
    /// Each name is resolved once and then sorted, so the sort itself does no locale lookups.
    static func options(locale: Locale = .current) -> [Option] {
        supportedCodes
            .map { Option(code: $0, name: displayName(for: $0, locale: locale)) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Options for the current locale, built once: the picker reads them on every view update.
    static let currentLocaleOptions = options()
}
