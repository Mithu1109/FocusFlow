//
//  FocusFlowTests.swift
//  FocusFlowTests
//
//  FocusFlow Smart Study Planner Unit Tests
//

import XCTest
import CoreData
@testable import FocusFlow

final class FocusFlowTests: XCTestCase {

    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!

    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }

    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }

    func testTaskPrioritySorting() throws {
        XCTAssertTrue(TaskPriority.high.sortOrder < TaskPriority.medium.sortOrder)
        XCTAssertTrue(TaskPriority.medium.sortOrder < TaskPriority.low.sortOrder)
        XCTAssertEqual(TaskPriority.high.title, "High")
    }

    func testSubjectModuleLookup() throws {
        let softEng = SubjectModule.module(named: "Software Engineering")
        XCTAssertEqual(softEng.code, "CS402")
        
        let research = SubjectModule.module(named: "Research & Dissertation")
        XCTAssertEqual(research.code, "RES501")
        
        let custom = SubjectModule.module(named: "Cloud Computing")
        XCTAssertEqual(custom.name, "Cloud Computing")
    }

    func testPomodoroModeDurations() throws {
        XCTAssertEqual(PomodoroMode.shortFocus.defaultMinutes, 25)
        XCTAssertEqual(PomodoroMode.standard.defaultMinutes, 45)
        XCTAssertEqual(PomodoroMode.deepFocus.defaultMinutes, 60)
    }

    func testSampleDataSeeding() throws {
        persistenceController.seedUniversitySampleData(context: context)
        
        let taskFetch: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let tasks = try context.fetch(taskFetch)
        XCTAssertFalse(tasks.isEmpty, "University sample tasks should be seeded")
        
        let sessionFetch: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        let sessions = try context.fetch(sessionFetch)
        XCTAssertFalse(sessions.isEmpty, "University sample study sessions should be seeded")
        
        let profileFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        let profile = try context.fetch(profileFetch).first
        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.unwrappedName, "Mithula")
        XCTAssertEqual(profile?.safeStreakCount, 5)
    }

    func testCoreMLStudyPredictor() throws {
        persistenceController.seedUniversitySampleData(context: context)
        
        let sessionFetch: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        let sessions = try context.fetch(sessionFetch)
        
        let taskFetch: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let tasks = try context.fetch(taskFetch)
        
        let recommendation = CoreMLStudyPredictor.shared.generateRecommendation(
            sessions: sessions,
            tasks: tasks
        )
        
        XCTAssertFalse(recommendation.smartPrompt.isEmpty)
        XCTAssertTrue(recommendation.confidenceScore >= 0.5)
        XCTAssertTrue(recommendation.recommendedDurationMinutes >= 25)
        XCTAssertFalse(recommendation.recommendedSubject.isEmpty)
        XCTAssertFalse(recommendation.formattedPeakTime.isEmpty)
    }

    @MainActor
    func testAnalyticsViewModelCalculations() throws {
        persistenceController.seedUniversitySampleData(context: context)
        
        let sessionFetch: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        let sessions = try context.fetch(sessionFetch)
        
        let viewModel = ProgressAnalyticsViewModel()
        let weekly = viewModel.calculateWeeklyData(sessions: sessions)
        XCTAssertEqual(weekly.count, 7, "Weekly data should represent 7 days")
        
        let breakdown = viewModel.calculateSubjectBreakdown(sessions: sessions)
        XCTAssertFalse(breakdown.isEmpty, "Subject breakdown should have items")
        
        let totalHours = viewModel.totalStudyHoursThisWeek(sessions: sessions)
        XCTAssertTrue(totalHours > 0, "Total study hours should be greater than zero")
    }

    func testTaskCompletionFlow() throws {
        let task = TaskItem(context: context)
        task.id = UUID()
        task.title = "Unit Testing SwiftUI Components"
        task.subject = "Software Engineering"
        task.priority = TaskPriority.high.rawValue
        task.dueDate = Date()
        task.isCompleted = false
        task.estimatedMinutes = 45
        
        try context.save()
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)
        
        // Complete the task
        task.isCompleted = true
        task.completedAt = Date()
        try context.save()
        
        XCTAssertTrue(task.isCompleted)
        XCTAssertNotNil(task.completedAt)
    }
}
