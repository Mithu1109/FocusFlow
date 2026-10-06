//
//  CoreDataExtensions.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import Foundation
import CoreData
import SwiftUI

// MARK: - TaskItem Extensions
extension TaskItem {
    var unwrappedId: UUID {
        id ?? UUID()
    }
    
    var unwrappedTitle: String {
        title ?? "Untitled Task"
    }
    
    var unwrappedSubject: String {
        subject ?? "General Study"
    }
    
    var taskPriority: TaskPriority {
        get {
            TaskPriority(rawValue: priority ?? "Medium") ?? .medium
        }
        set {
            priority = newValue.rawValue
        }
    }
    
    var unwrappedDueDate: Date {
        dueDate ?? Date()
    }
    
    var unwrappedCreatedAt: Date {
        createdAt ?? Date()
    }
    
    var subjectModule: SubjectModule {
        SubjectModule.module(named: unwrappedSubject)
    }
    
    var isOverdue: Bool {
        guard !isCompleted, let due = dueDate else { return false }
        return due < Date()
    }
    
    var isDueToday: Bool {
        guard let due = dueDate else { return false }
        return Calendar.current.isDateInToday(due)
    }
    
    var relativeDueString: String {
        guard let due = dueDate else { return "No due date" }
        let calendar = Calendar.current
        if isCompleted {
            return "Completed"
        }
        if calendar.isDateInToday(due) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today at \(formatter.string(from: due))"
        } else if calendar.isDateInTomorrow(due) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(due) {
            return "Yesterday · Overdue"
        } else if due < Date() {
            let days = calendar.dateComponents([.day], from: due, to: Date()).day ?? 1
            return "\(days)d overdue"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, MMM d"
            return formatter.string(from: due)
        }
    }
}

// MARK: - StudySession Extensions
extension StudySession {
    var unwrappedId: UUID {
        id ?? UUID()
    }
    
    var unwrappedSubject: String {
        subject ?? "General Study"
    }
    
    var unwrappedStartTime: Date {
        startTime ?? Date()
    }
    
    var unwrappedEndTime: Date {
        endTime ?? Date()
    }
    
    var unwrappedMode: String {
        sessionMode ?? "Standard"
    }
    
    var subjectModule: SubjectModule {
        SubjectModule.module(named: unwrappedSubject)
    }
    
    var formattedDuration: String {
        let mins = Int(durationMinutes)
        if mins >= 60 {
            let hours = mins / 60
            let rem = mins % 60
            return rem > 0 ? "\(hours)h \(rem)m" : "\(hours)h"
        } else {
            return "\(mins) min"
        }
    }
}

// MARK: - UserProfile Extensions
extension UserProfile {
    var unwrappedName: String {
        name ?? "Mithula"
    }
    
    var safeStreakCount: Int {
        Int(streakCount)
    }
    
    var safeDailyGoal: Double {
        dailyGoalHours > 0 ? dailyGoalHours : 3.0
    }
    
    var safeDefaultPomodoroMinutes: Int {
        defaultPomodoroMinutes > 0 ? Int(defaultPomodoroMinutes) : 25
    }
}
