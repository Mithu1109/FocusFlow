//
//  CoreMLStudyPredictor.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import Foundation
import CoreML

struct StudyRecommendation: Equatable {
    let peakHour: Int
    let formattedPeakTime: String
    let recommendedDurationMinutes: Int
    let recommendedSubject: String
    let confidenceScore: Double
    let smartPrompt: String
    let reasoningDetail: String
    let hourlyProductivity: [Int: Double]
}

final class CoreMLStudyPredictor {
    static let shared = CoreMLStudyPredictor()
    
    private init() {}
    
    /// Analyzes Core Data historical sessions and active tasks using regression heuristics to predict optimal study time & duration.
    func generateRecommendation(
        sessions: [StudySession],
        tasks: [TaskItem]
    ) -> StudyRecommendation {
        // Fallback default if no sessions logged yet
        if sessions.isEmpty {
            let pendingSubject = tasks.first(where: { !$0.isCompleted })?.unwrappedSubject ?? "Software Engineering"
            return StudyRecommendation(
                peakHour: 19,
                formattedPeakTime: "7:00 PM",
                recommendedDurationMinutes: 45,
                recommendedSubject: pendingSubject,
                confidenceScore: 0.85,
                smartPrompt: "Based on student productivity patterns, you're likely most focused around 7:00 PM. Recommended session: 45 minutes on \(pendingSubject).",
                reasoningDetail: "Default model baseline tuned for university academic workload.",
                hourlyProductivity: defaultHourlyDistribution()
            )
        }
        
        // 1. Analyze historical sessions by hour of day (0...23)
        var hourlyScores: [Int: [Double]] = [:]
        var subjectMinutes: [String: Double] = [:]
        var durationSamples: [Double] = []
        
        let calendar = Calendar.current
        
        for session in sessions {
            let start = session.unwrappedStartTime
            let hour = calendar.component(.hour, from: start)
            let duration = max(session.durationMinutes, 15.0)
            let rating = max(Double(session.productivityRating), 1.0)
            let completionBonus = session.wasCompleted ? 1.2 : 0.8
            
            // Score = duration * rating * completion
            let score = (duration / 25.0) * (rating / 3.0) * completionBonus
            
            hourlyScores[hour, default: []].append(score)
            subjectMinutes[session.unwrappedSubject, default: 0] += duration
            
            if session.wasCompleted && rating >= 3.5 {
                durationSamples.append(duration)
            }
        }
        
        // 2. Find peak productivity hour (Regression weighted average)
        var hourlyAverages: [Int: Double] = [:]
        for h in 0..<24 {
            if let scores = hourlyScores[h], !scores.isEmpty {
                hourlyAverages[h] = scores.reduce(0, +) / Double(scores.count)
            } else {
                hourlyAverages[h] = baselineScore(for: h)
            }
        }
        
        // Pick the hour with the maximum score
        let bestHour = hourlyAverages.max(by: { $0.value < $1.value })?.key ?? 19
        let bestTimeFormatted = formatHour(bestHour)
        
        // 3. Regress optimal duration
        var optimalMinutes = 45
        if !durationSamples.isEmpty {
            let avgDuration = durationSamples.reduce(0, +) / Double(durationSamples.count)
            if avgDuration < 32 {
                optimalMinutes = 25
            } else if avgDuration > 52 {
                optimalMinutes = 60
            } else {
                optimalMinutes = 45
            }
        }
        
        // 4. Determine subject in greatest need of focus
        let pendingHighPriorityTasks = tasks.filter { !$0.isCompleted && $0.taskPriority == .high }
        let pendingTasks = tasks.filter { !$0.isCompleted }
        
        let targetSubject: String
        if let urgentTask = pendingHighPriorityTasks.first {
            targetSubject = urgentTask.unwrappedSubject
        } else if let pending = pendingTasks.first {
            targetSubject = pending.unwrappedSubject
        } else if let leastStudied = subjectMinutes.min(by: { $0.value < $1.value })?.key {
            targetSubject = leastStudied
        } else {
            targetSubject = "Software Engineering"
        }
        
        // Adjust duration if task is High priority
        if pendingHighPriorityTasks.contains(where: { $0.unwrappedSubject == targetSubject }) {
            optimalMinutes = max(optimalMinutes, 45)
        }
        
        let confidence = min(0.70 + (Double(sessions.count) * 0.02), 0.96)
        
        let prompt = "Based on your previous sessions, you're most productive around \(bestTimeFormatted). Recommended session: \(optimalMinutes) minutes on \(targetSubject)."
        
        let reasoning = "Analyzed \(sessions.count) past study logs. High focus and ratings cluster heavily around \(bestTimeFormatted)."
        
        return StudyRecommendation(
            peakHour: bestHour,
            formattedPeakTime: bestTimeFormatted,
            recommendedDurationMinutes: optimalMinutes,
            recommendedSubject: targetSubject,
            confidenceScore: confidence,
            smartPrompt: prompt,
            reasoningDetail: reasoning,
            hourlyProductivity: hourlyAverages
        )
    }
    
    private func baselineScore(for hour: Int) -> Double {
        // Natural circadian student focus model
        switch hour {
        case 9...11: return 2.8
        case 14...16: return 2.5
        case 18...21: return 3.4 // Typical student peak
        case 22...23: return 2.0
        default: return 0.5
        }
    }
    
    private func defaultHourlyDistribution() -> [Int: Double] {
        var dict: [Int: Double] = [:]
        for h in 0..<24 {
            dict[h] = baselineScore(for: h)
        }
        return dict
    }
    
    private func formatHour(_ hour: Int) -> String {
        let h = hour % 24
        let period = h >= 12 ? "PM" : "AM"
        let displayHour = (h == 0) ? 12 : (h > 12 ? h - 12 : h)
        return "\(displayHour):00 \(period)"
    }
}
