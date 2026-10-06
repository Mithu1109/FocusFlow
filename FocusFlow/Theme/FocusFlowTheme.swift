//
//  FocusFlowTheme.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

enum FocusFlowTheme {
    // Primary Brand Colors from specifications
    static let primary = Color(hex: "5B6CFF")
    static let primaryLight = Color(hex: "7C8AFF")
    static let primaryDark = Color(hex: "4351D9")
    
    // Backgrounds
    static let backgroundLight = Color(hex: "F7F8FC")
    static let backgroundDark = Color(hex: "0D0F18")
    
    // Card Backgrounds
    static let cardLight = Color.white
    static let cardDark = Color(hex: "171926")
    static let cardBorderLight = Color(hex: "E5E8F2")
    static let cardBorderDark = Color(hex: "25293C")
    
    // Secondary / Element Backgrounds (for pills, unselected buttons, chips)
    static let secondaryCardLight = Color.white
    static let secondaryCardDark = Color(hex: "1F2336")
    
    // Form / Input Backgrounds
    static let inputBackgroundLight = Color(hex: "F0F2F8")
    static let inputBackgroundDark = Color(hex: "1A1D2D")
    
    // Text Colors
    static let textLight = Color(hex: "20232A")
    static let textDark = Color(hex: "F3F4F8")
    static let textSecondaryLight = Color(hex: "6B7280")
    static let textSecondaryDark = Color(hex: "9CA3AF")
    
    // Accents
    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")
    static let highPriority = Color(hex: "EF4444")
    static let cyan = Color(hex: "06B6D4")
    static let purple = Color(hex: "8B5CF6")
    static let orange = Color(hex: "F97316")
    
    // MARK: - Dynamic Theme Helpers
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : backgroundLight
    }
    
    static func card(for scheme: ColorScheme) -> Color {
        scheme == .dark ? cardDark : cardLight
    }
    
    static func secondaryCard(for scheme: ColorScheme) -> Color {
        scheme == .dark ? secondaryCardDark : secondaryCardLight
    }
    
    static func cardBorder(for scheme: ColorScheme) -> Color {
        scheme == .dark ? cardBorderDark : cardBorderLight
    }
    
    static func inputBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? inputBackgroundDark : inputBackgroundLight
    }
    
    static func text(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textDark : textLight
    }
    
    static func textSecondary(for scheme: ColorScheme) -> Color {
        scheme == .dark ? textSecondaryDark : textSecondaryLight
    }
    
    static func chipBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.08) : Color.gray.opacity(0.08)
    }
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, Color(hex: "7952F5")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func aiCardGradient(for scheme: ColorScheme) -> LinearGradient {
        if scheme == .dark {
            return LinearGradient(
                colors: [Color(hex: "1A1D30"), Color(hex: "201A38")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "EEF2FF"), Color(hex: "F5F3FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    static func aiPromptBoxBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(hex: "121422").opacity(0.9) : Color.white.opacity(0.85)
    }
    
    static let aiGlowGradient = LinearGradient(
        colors: [Color(hex: "5B6CFF").opacity(0.15), Color(hex: "8B5CF6").opacity(0.12), Color(hex: "06B6D4").opacity(0.08)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let timerGradient = LinearGradient(
        colors: [Color(hex: "5B6CFF"), Color(hex: "38BDF8")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let flameGradient = LinearGradient(
        colors: [Color(hex: "FF6B35"), Color(hex: "F59E0B")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct FocusFlowCardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 18
    var hasBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(FocusFlowTheme.card(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        hasBorder ? FocusFlowTheme.cardBorder(for: colorScheme) : Color.clear,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.35) : Color(hex: "1F2644").opacity(0.06),
                radius: 10,
                x: 0,
                y: 4
            )
    }
}

struct FocusFlowBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(FocusFlowTheme.background(for: colorScheme).ignoresSafeArea())
    }
}

extension View {
    func focusFlowCard(cornerRadius: CGFloat = 18, hasBorder: Bool = true) -> some View {
        self.modifier(FocusFlowCardModifier(cornerRadius: cornerRadius, hasBorder: hasBorder))
    }
    
    func focusFlowBackground() -> some View {
        self.modifier(FocusFlowBackgroundModifier())
    }
}
