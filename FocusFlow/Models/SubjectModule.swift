//
//  SubjectModule.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct SubjectModule: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let code: String
    let iconName: String
    let hexColor: String
    
    var color: Color {
        Color(hex: hexColor)
    }
    
    static let defaultModules: [SubjectModule] = [
        SubjectModule(
            id: "soft_eng",
            name: "Software Engineering",
            code: "CS402",
            iconName: "chevron.left.forwardslash.chevron.right",
            hexColor: "5B6CFF"
        ),
        SubjectModule(
            id: "research",
            name: "Research & Dissertation",
            code: "RES501",
            iconName: "doc.text.magnifyingglass",
            hexColor: "8B5CF6"
        ),
        SubjectModule(
            id: "ai_ml",
            name: "Artificial Intelligence",
            code: "AI410",
            iconName: "brain.head.profile",
            hexColor: "06B6D4"
        ),
        SubjectModule(
            id: "data_struct",
            name: "Data Structures & Algo",
            code: "CS201",
            iconName: "network",
            hexColor: "10B981"
        ),
        SubjectModule(
            id: "maths",
            name: "Mathematics for Computing",
            code: "MAT202",
            iconName: "function",
            hexColor: "F59E0B"
        ),
        SubjectModule(
            id: "hci",
            name: "Human-Computer Interaction",
            code: "CS305",
            iconName: "hand.tap.fill",
            hexColor: "EC4899"
        ),
        SubjectModule(
            id: "general",
            name: "General Study",
            code: "GEN100",
            iconName: "book.fill",
            hexColor: "6366F1"
        )
    ]
    
    static func module(named name: String) -> SubjectModule {
        if let match = defaultModules.first(where: { $0.name.lowercased() == name.lowercased() }) {
            return match
        }
        return SubjectModule(
            id: name.lowercased().replacingOccurrences(of: " ", with: "_"),
            name: name,
            code: "MOD",
            iconName: "book.closed.fill",
            hexColor: "5B6CFF"
        )
    }
}
