//
//  ProgressAnalyticsViewModel.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData
import Combine

struct DayStudyData: Identifiable, Equatable {
    let id = UUID()
    let dayName: String
    let fullDate: Date
    let hours: Double
    let sessionCount: Int
    let isToday: Bool
}

struct SubjectBreakdownItem: Identifiable, Equatable {
    var id: String { subjectName }
    let subjectName: String
    let hours: Double
    let percentage: Double
    let color: Color
    let iconName: String
    let sessionCount: Int
}

@MainActor
final class ProgressAnalyticsViewModel: ObservableObject {
    @Published var selectedDayData: DayStudyData? = nil
    
    // MARK: - Weekly Chart Data
    func calculateWeeklyData(sessions: [StudySession]) -> [DayStudyData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var results: [DayStudyData] = []
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        // Past 7 days from (today - 6 days) up to today
        for offset in (0..<7).reversed() {
            guard let targetDate = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let daySessions = sessions.filter { session in
                calendar.isDate(session.unwrappedStartTime, inSameDayAs: targetDate)
            }
            
            let totalMinutes = daySessions.reduce(0.0) { $0 + $1.durationMinutes }
            let hours = totalMinutes / 60.0
            let dayName = dayFormatter.string(from: targetDate)
            let isToday = calendar.isDateInToday(targetDate)
            
            results.append(
                DayStudyData(
                    dayName: dayName,
                    fullDate: targetDate,
                    hours: (hours * 10).rounded() / 10,
                    sessionCount: daySessions.count,
                    isToday: isToday
                )
            )
        }
        
        return results
    }
    
    // MARK: - Subject Breakdown Data
    func calculateSubjectBreakdown(sessions: [StudySession]) -> [SubjectBreakdownItem] {
        guard !sessions.isEmpty else { return [] }
        
        var grouped: [String: (minutes: Double, count: Int)] = [:]
        for session in sessions {
            let subj = session.unwrappedSubject
            let existing = grouped[subj] ?? (0.0, 0)
            grouped[subj] = (existing.minutes + session.durationMinutes, existing.count + 1)
        }
        
        let totalMinutes = max(grouped.values.reduce(0.0) { $0 + $1.minutes }, 1.0)
        
        var items: [SubjectBreakdownItem] = []
        for (subj, info) in grouped {
            let module = SubjectModule.module(named: subj)
            let hours = (info.minutes / 60.0 * 10).rounded() / 10
            let percentage = (info.minutes / totalMinutes) * 100.0
            
            items.append(
                SubjectBreakdownItem(
                    subjectName: subj,
                    hours: hours,
                    percentage: (percentage * 10).rounded() / 10,
                    color: module.color,
                    iconName: module.iconName,
                    sessionCount: info.count
                )
            )
        }
        
        return items.sorted { $0.hours > $1.hours }
    }
    
    // MARK: - Total Statistics
    func totalStudyHoursThisWeek(sessions: [StudySession]) -> Double {
        let weekly = calculateWeeklyData(sessions: sessions)
        let total = weekly.reduce(0.0) { $0 + $1.hours }
        return (total * 10).rounded() / 10
    }
    
    func dailyAverageHours(sessions: [StudySession]) -> Double {
        let weekly = calculateWeeklyData(sessions: sessions)
        guard !weekly.isEmpty else { return 0.0 }
        let total = weekly.reduce(0.0) { $0 + $1.hours }
        let avg = total / Double(weekly.count)
        return (avg * 10).rounded() / 10
    }
    
    func totalSessionsCount(sessions: [StudySession]) -> Int {
        sessions.count
    }
    
    func completionRate(sessions: [StudySession]) -> Int {
        guard !sessions.isEmpty else { return 100 }
        let completed = sessions.filter { $0.wasCompleted }.count
        return Int((Double(completed) / Double(sessions.count)) * 100)
    }
    
    // MARK: - Core ML Recommendation
    func getRecommendation(sessions: [StudySession], tasks: [TaskItem]) -> StudyRecommendation {
        CoreMLStudyPredictor.shared.generateRecommendation(sessions: sessions, tasks: tasks)
    }
}
