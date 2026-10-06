//
//  DashboardViewModel.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData
import Combine

enum TaskFilter: String, CaseIterable, Identifiable {
    case pending = "Pending"
    case all = "All Tasks"
    case completed = "Completed"
    
    var id: String { rawValue }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var selectedFilter: TaskFilter = .pending
    @Published var isShowingAddTaskSheet: Bool = false
    @Published var isShowingSettingsSheet: Bool = false
    
    // Personalized greeting based on current time
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        default:
            return "Good evening"
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    var motivationalMessage: String {
        let quotes = [
            "Small daily disciplines lead to massive academic breakthroughs.",
            "Deep focus is a superpower. Own your study sessions today.",
            "Progress over perfection. One focused Pomodoro at a time.",
            "Stay relentless with your goals, flexible with your methods.",
            "Your future self will thank you for the effort you put in right now."
        ]
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return quotes[dayOfYear % quotes.count]
    }
    
    // Toggle completion with haptic feedback
    func toggleTaskCompletion(task: TaskItem, context: NSManagedObjectContext) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            task.isCompleted.toggle()
            if task.isCompleted {
                task.completedAt = Date()
                HapticManager.shared.success()
            } else {
                task.completedAt = nil
                HapticManager.shared.light()
            }
            try? context.save()
        }
    }
    
    // Delete task
    func deleteTask(task: TaskItem, context: NSManagedObjectContext) {
        withAnimation {
            HapticManager.shared.warning()
            context.delete(task)
            try? context.save()
        }
    }
    
    // Quick add task
    func addTask(
        title: String,
        subject: String,
        priority: TaskPriority,
        dueDate: Date,
        estimatedMinutes: Int,
        notes: String,
        context: NSManagedObjectContext
    ) {
        let newTask = TaskItem(context: context)
        newTask.id = UUID()
        newTask.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        newTask.subject = subject
        newTask.priority = priority.rawValue
        newTask.dueDate = dueDate
        newTask.estimatedMinutes = Int32(estimatedMinutes)
        newTask.createdAt = Date()
        newTask.isCompleted = false
        newTask.notes = notes.isEmpty ? nil : notes
        
        try? context.save()
        HapticManager.shared.success()
        
        // Schedule notification reminder if High priority
        if priority == .high {
            NotificationManager.shared.scheduleTaskDueReminder(for: newTask)
        }
    }
    
    // Calculate today's study minutes from sessions
    func calculateTodayStudyMinutes(sessions: [StudySession]) -> Int {
        let calendar = Calendar.current
        let todaySessions = sessions.filter { session in
            calendar.isDateInToday(session.unwrappedStartTime)
        }
        return Int(todaySessions.reduce(0) { $0 + $1.durationMinutes })
    }
    
    // Filter tasks
    func filteredTasks(tasks: [TaskItem]) -> [TaskItem] {
        switch selectedFilter {
        case .pending:
            return tasks.filter { !$0.isCompleted }
                .sorted { (t1, t2) -> Bool in
                    if t1.taskPriority.sortOrder != t2.taskPriority.sortOrder {
                        return t1.taskPriority.sortOrder < t2.taskPriority.sortOrder
                    }
                    return t1.unwrappedDueDate < t2.unwrappedDueDate
                }
        case .completed:
            return tasks.filter { $0.isCompleted }
                .sorted { ($0.completedAt ?? Date()) > ($1.completedAt ?? Date()) }
        case .all:
            return tasks.sorted { (t1, t2) -> Bool in
                if t1.isCompleted != t2.isCompleted {
                    return !t1.isCompleted
                }
                return t1.unwrappedDueDate < t2.unwrappedDueDate
            }
        }
    }
}
