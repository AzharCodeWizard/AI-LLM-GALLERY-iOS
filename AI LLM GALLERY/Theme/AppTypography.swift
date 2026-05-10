//
//  AppTypography.swift
//  AI LLM GALLERY
//

import SwiftUI

// MARK: - Typography Extensions matching Android Material 3

extension Font {
    // ── Display ──
    static var displayLarge: Font { .system(size: 57, weight: .regular) }
    static var displayMedium: Font { .system(size: 45, weight: .regular) }
    static var displaySmall: Font { .system(size: 36, weight: .regular) }

    // ── Headline ──
    static var headlineLarge: Font { .system(size: 32, weight: .regular) }
    static var headlineMedium: Font { .system(size: 28, weight: .regular) }
    static var headlineSmall: Font { .system(size: 24, weight: .regular) }

    // ── Title ──
    static var titleLarge: Font { .system(size: 22, weight: .regular) }
    static var titleMedium: Font { .system(size: 16, weight: .medium) }
    static var titleSmall: Font { .system(size: 14, weight: .medium) }

    // ── Body ──
    static var bodyLarge: Font { .system(size: 16, weight: .regular) }
    static var bodyMedium: Font { .system(size: 14, weight: .regular) }
    static var bodySmall: Font { .system(size: 12, weight: .regular) }

    // ── Label ──
    static var labelLarge: Font { .system(size: 14, weight: .medium) }
    static var labelMedium: Font { .system(size: 12, weight: .medium) }
    static var labelSmall: Font { .system(size: 11, weight: .medium) }
}
