//
//  AppColors.swift
//  AI LLM GALLERY
//

import SwiftUI

// MARK: - Primary Palette: Deep Indigo → Electric Cyan

enum AppColors {
    // ── Primary: Indigo ──
    static let indigo80 = Color(red: 0.73, green: 0.76, blue: 1.0)     // #BBC3FF
    static let indigo60 = Color(red: 0.55, green: 0.59, blue: 1.0)     // #8B97FF
    static let indigo40 = Color(red: 0.36, green: 0.39, blue: 0.88)    // #5B63E0
    static let indigo20 = Color(red: 0.24, green: 0.25, blue: 0.63)    // #3D3FA0
    static let indigo10 = Color(red: 0.12, green: 0.12, blue: 0.37)    // #1E1F5E

    // ── Secondary: Cyan ──
    static let cyan80 = Color(red: 0.63, green: 0.94, blue: 0.93)      // #A0F0ED
    static let cyan60 = Color(red: 0.30, green: 0.85, blue: 0.82)      // #4DD9D2
    static let cyan40 = Color(red: 0.0, green: 0.71, blue: 0.67)       // #00B4AB
    static let cyan20 = Color(red: 0.0, green: 0.48, blue: 0.46)       // #007A75
    static let cyan10 = Color(red: 0.0, green: 0.22, blue: 0.21)       // #003735

    // ── Tertiary: Amber ──
    static let amber80 = Color(red: 1.0, green: 0.87, blue: 0.65)      // #FFDEA6
    static let amber60 = Color(red: 1.0, green: 0.73, blue: 0.22)      // #FFBB38
    static let amber40 = Color(red: 0.88, green: 0.60, blue: 0.0)      // #E09800
    static let amber20 = Color(red: 0.55, green: 0.37, blue: 0.0)      // #8C5E00
    static let amber10 = Color(red: 0.29, green: 0.19, blue: 0.0)      // #4A3000

    // ── Neutrals ──
    static let neutral99 = Color(red: 0.99, green: 0.99, blue: 1.0)    // #FCFCFF
    static let neutral95 = Color(red: 0.94, green: 0.94, blue: 0.97)   // #F0F0F8
    static let neutral90 = Color(red: 0.88, green: 0.88, blue: 0.93)   // #E1E1EC
    static let neutral80 = Color(red: 0.77, green: 0.77, blue: 0.83)   // #C4C4D4
    static let neutral30 = Color(red: 0.27, green: 0.27, blue: 0.31)   // #46464F
    static let neutral20 = Color(red: 0.18, green: 0.18, blue: 0.22)   // #2E2E38
    static let neutral10 = Color(red: 0.10, green: 0.10, blue: 0.14)   // #1A1A24
    static let neutral05 = Color(red: 0.06, green: 0.06, blue: 0.09)   // #0F0F18

    // ── Error ──
    static let error80 = Color(red: 1.0, green: 0.71, blue: 0.67)      // #FFB4AB
    static let error40 = Color(red: 0.87, green: 0.22, blue: 0.19)     // #DE3730

    // ── Gradient Colors for Capability Cards ──
    static let gradientTextStart = Color(hex: 0x667EEA)
    static let gradientTextEnd = Color(hex: 0x764BA2)
    static let gradientVisionStart = Color(hex: 0x00C9FF)
    static let gradientVisionEnd = Color(hex: 0x00B4AB)
    static let gradientMultimodalStart = Color(hex: 0xF857A6)
    static let gradientMultimodalEnd = Color(hex: 0xFF5858)
    static let gradientCodeStart = Color(hex: 0x11998E)
    static let gradientCodeEnd = Color(hex: 0x38EF7D)

    // ── Quiz Gradients ──
    static let quizGradientStart = Color(hex: 0x6366F1)
    static let quizGradientEnd = Color(hex: 0x8B5CF6)

    // ── Feedback Colors ──
    static let success = Color(hex: 0x22C55E)
    static let warning = Color(hex: 0xF59E0B)
    static let danger = Color(hex: 0xEF4444)
}

// MARK: - Color Hex Initializer

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Adaptive Theme Colors

extension Color {
    /// Primary color that adapts to color scheme
    static var appPrimary: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.indigo80)
                : UIColor(AppColors.indigo40)
        })
    }

    static var appOnPrimary: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.indigo10)
                : UIColor(AppColors.neutral99)
        })
    }

    static var appPrimaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.indigo20)
                : UIColor(AppColors.indigo80)
        })
    }

    static var appOnPrimaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.indigo80)
                : UIColor(AppColors.indigo10)
        })
    }

    static var appSecondary: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.cyan80)
                : UIColor(AppColors.cyan40)
        })
    }

    static var appSecondaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.cyan20)
                : UIColor(AppColors.cyan80)
        })
    }

    static var appOnSecondaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.cyan80)
                : UIColor(AppColors.cyan10)
        })
    }

    static var appTertiary: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.amber80)
                : UIColor(AppColors.amber40)
        })
    }

    static var appTertiaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.amber20)
                : UIColor(AppColors.amber80)
        })
    }

    static var appOnTertiaryContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.amber80)
                : UIColor(AppColors.amber10)
        })
    }

    static var appError: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.error80)
                : UIColor(AppColors.error40)
        })
    }

    static var appErrorContainer: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.error40).withAlphaComponent(0.3)
                : UIColor(AppColors.error80).withAlphaComponent(0.3)
        })
    }

    static var appBackground: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral05)
                : UIColor(AppColors.neutral99)
        })
    }

    static var appOnBackground: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral90)
                : UIColor(AppColors.neutral10)
        })
    }

    static var appSurface: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral10)
                : UIColor(AppColors.neutral95)
        })
    }

    static var appOnSurface: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral90)
                : UIColor(AppColors.neutral10)
        })
    }

    static var appSurfaceVariant: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral20)
                : UIColor(AppColors.neutral90)
        })
    }

    static var appOnSurfaceVariant: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral80)
                : UIColor(AppColors.neutral30)
        })
    }

    static var appOutline: Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(AppColors.neutral30)
                : UIColor(AppColors.neutral80)
        })
    }
}
