//
//  TaskPriority.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var color: Color {
        switch self {
        case .high:
            return FocusFlowTheme.highPriority
        case .medium:
            return FocusFlowTheme.warning
        case .low:
            return FocusFlowTheme.success
        }
    }
    
    var icon: String {
        switch self {
        case .high:
            return "exclamationmark.3"
        case .medium:
            return "exclamationmark.2"
        case .low:
            return "exclamationmark"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}
