//
//  PomodoroViewModel.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData
import Combine

enum TimerState {
    case idle
    case running
    case paused
    case completed
}

enum AmbientSound: String, CaseIterable, Identifiable {
    case silent = "Mute"
    case lofi = "Lo-Fi Study"
    case rain = "Soft Rain"
    case whiteNoise = "White Noise"
    case forest = "Forest Ambience"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .silent: return "speaker.slash.fill"
        case .lofi: return "headphones"
        case .rain: return "cloud.rain.fill"
        case .whiteNoise: return "waveform"
        case .forest: return "leaf.fill"
        }
    }
}

@MainActor
final class PomodoroViewModel: ObservableObject {
    @Published var selectedMode: PomodoroMode = .shortFocus {
        didSet {
            if timerState == .idle {
                resetTimerDuration()
            }
        }
    }
    
    @Published var customMinutes: Int = 30 {
        didSet {
            if selectedMode == .custom && timerState == .idle {
                totalSeconds = customMinutes * 60
                secondsRemaining = totalSeconds
            }
        }
    }
    
    @Published var selectedSubject: String = "Software Engineering"
    @Published var selectedTask: TaskItem? = nil
    @Published var selectedSound: AmbientSound = .silent
    
    @Published var timerState: TimerState = .idle
    @Published var secondsRemaining: Int = 25 * 60
    @Published var totalSeconds: Int = 25 * 60
    @Published var sessionStartTime: Date? = nil
    
    @Published var isShowingCompletionSheet: Bool = false
    @Published var completedDurationMinutes: Double = 25.0
    
    private var timerCancellable: AnyCancellable? = nil
    
    init() {
        resetTimerDuration()
    }
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0.0 }
        return Double(totalSeconds - secondsRemaining) / Double(totalSeconds)
    }
    
    var formattedTime: String {
        let minutes = secondsRemaining / 60
        let seconds = secondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func resetTimerDuration() {
        let minutes: Int
        switch selectedMode {
        case .shortFocus: minutes = 25
        case .standard: minutes = 45
        case .deepFocus: minutes = 60
        case .custom: minutes = customMinutes
        }
        totalSeconds = minutes * 60
        secondsRemaining = totalSeconds
        timerState = .idle
        sessionStartTime = nil
        timerCancellable?.cancel()
    }
    
    // MARK: - Timer Controls
    func startTimer() {
        HapticManager.shared.medium()
        if sessionStartTime == nil {
            sessionStartTime = Date()
        }
        timerState = .running
        
        // Schedule notification
        let mins = max(secondsRemaining / 60, 1)
        NotificationManager.shared.scheduleTimerCompletionNotification(subject: selectedSubject, minutes: mins)
        
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.secondsRemaining > 0 {
                    self.secondsRemaining -= 1
                } else {
                    self.handleTimerComplete()
                }
            }
    }
    
    func pauseTimer() {
        HapticManager.shared.light()
        timerState = .paused
        timerCancellable?.cancel()
    }
    
    func resumeTimer() {
        startTimer()
    }
    
    func resetTimer() {
        HapticManager.shared.warning()
        resetTimerDuration()
    }
    
    func endSessionEarly(context: NSManagedObjectContext) {
        HapticManager.shared.warning()
        timerCancellable?.cancel()
        
        let elapsed = Double(totalSeconds - secondsRemaining) / 60.0
        if elapsed >= 5.0 { // Log if studied at least 5 minutes
            completedDurationMinutes = Double(Int(elapsed))
            isShowingCompletionSheet = true
        } else {
            resetTimerDuration()
        }
    }
    
    private func handleTimerComplete() {
        timerCancellable?.cancel()
        timerState = .completed
        HapticManager.shared.success()
        completedDurationMinutes = Double(totalSeconds / 60)
        isShowingCompletionSheet = true
    }
    
    // MARK: - Automatic Logging to Core Data
    func saveCompletedSession(
        productivityRating: Int,
        notes: String,
        context: NSManagedObjectContext
    ) {
        let session = StudySession(context: context)
        session.id = UUID()
        session.subject = selectedSubject
        session.durationMinutes = completedDurationMinutes
        session.startTime = sessionStartTime ?? Date().addingTimeInterval(-completedDurationMinutes * 60)
        session.endTime = Date()
        session.sessionMode = selectedMode.shortTitle
        session.productivityRating = Int16(productivityRating)
        session.wasCompleted = (secondsRemaining == 0)
        session.notes = notes.isEmpty ? "Focused session on \(selectedSubject)." : notes
        
        // Update user streak & last study date
        let profileFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        if let profile = try? context.fetch(profileFetch).first {
            let calendar = Calendar.current
            if let lastDate = profile.lastStudyDate {
                if calendar.isDateInYesterday(lastDate) {
                    profile.streakCount += 1
                } else if !calendar.isDateInToday(lastDate) {
                    profile.streakCount = 1
                }
            } else {
                profile.streakCount = 1
            }
            profile.lastStudyDate = Date()
        }
        
        // If tied to a task, optionally check it off or append notes
        if let task = selectedTask {
            if secondsRemaining == 0 {
                task.isCompleted = true
                task.completedAt = Date()
            }
        }
        
        do {
            try context.save()
            HapticManager.shared.success()
        } catch {
            print("Failed to save study session: \(error)")
        }
        
        isShowingCompletionSheet = false
        resetTimerDuration()
    }
    
    // Quick helper to pre-fill from AI Recommendation
    func applyRecommendation(subject: String, minutes: Int) {
        selectedSubject = subject
        if minutes == 25 {
            selectedMode = .shortFocus
        } else if minutes == 45 {
            selectedMode = .standard
        } else if minutes == 60 {
            selectedMode = .deepFocus
        } else {
            selectedMode = .custom
            customMinutes = minutes
        }
        resetTimerDuration()
    }
}
