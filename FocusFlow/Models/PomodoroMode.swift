//
//  PomodoroMode.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

enum PomodoroMode: String, CaseIterable, Identifiable {
    case shortFocus = "25 min Short Focus"
    case standard = "45 min Standard"
    case deepFocus = "60 min Deep Focus"
    case custom = "Custom Duration"
    
    var id: String { rawValue }
    
    var shortTitle: String {
        switch self {
        case .shortFocus: return "25m Short"
        case .standard: return "45m Standard"
        case .deepFocus: return "60m Deep"
        case .custom: return "Custom"
        }
    }
    
    var defaultMinutes: Int {
        switch self {
        case .shortFocus: return 25
        case .standard: return 45
        case .deepFocus: return 60
        case .custom: return 30
        }
    }
    
    var iconName: String {
        switch self {
        case .shortFocus: return "bolt.fill"
        case .standard: return "target"
        case .deepFocus: return "brain.head.profile"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .shortFocus: return FocusFlowTheme.cyan
        case .standard: return FocusFlowTheme.primary
        case .deepFocus: return FocusFlowTheme.purple
        case .custom: return FocusFlowTheme.orange
        }
    }
}
