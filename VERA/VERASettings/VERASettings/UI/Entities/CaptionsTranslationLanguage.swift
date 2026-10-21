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

    /// Localized language name (native equivalent of Web `Intl.DisplayNames`), falling back to the code.
    public static func displayName(for code: String, locale: Locale = .current) -> String {
        locale.localizedString(forIdentifier: code) ?? code
    }

    /// Supported codes ordered by their localized name so the picker is easy to scan.
    public static func sortedCodes(locale: Locale = .current) -> [String] {
        supportedCodes.sorted {
            displayName(for: $0, locale: locale).localizedStandardCompare(displayName(for: $1, locale: locale))
                == .orderedAscending
        }
    }
}
