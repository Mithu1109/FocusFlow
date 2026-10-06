//
//  Persistence.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        result.seedUniversitySampleData(context: viewContext)
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        if let modelURL = Bundle.main.url(forResource: "FocusFlow", withExtension: "momd"),
           let model = NSManagedObjectModel(contentsOf: modelURL) {
            container = NSPersistentContainer(name: "FocusFlow", managedObjectModel: model)
        } else {
            container = NSPersistentContainer(name: "FocusFlow")
        }
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Context Helper
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Seed Realistic University Sample Data
    func seedUniversitySampleData(context: NSManagedObjectContext) {
        // 1. User Profile
        let profileFetch: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        let existingProfiles = (try? context.fetch(profileFetch)) ?? []
        if existingProfiles.isEmpty {
            let profile = UserProfile(context: context)
            profile.id = UUID()
            profile.name = "Mithula"
            profile.streakCount = 5
            profile.lastStudyDate = Date()
            profile.defaultPomodoroMinutes = 25
            profile.dailyGoalHours = 3.5
        }
        
        // 2. Active Tasks
        let taskFetch: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let existingTasks = (try? context.fetch(taskFetch)) ?? []
        if existingTasks.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            
            let sampleTasks: [(title: String, subject: String, priority: TaskPriority, daysFromNow: Int, estMin: Int32, notes: String)] = [
                ("Complete System Architecture Diagram", "Software Engineering", .high, 0, 45, "Draw component & sequence diagrams for microservices"),
                ("Literature Review on Transformer Attention", "Research & Dissertation", .high, 1, 90, "Review 5 IEEE papers on sparse attention mechanisms"),
                ("Implement Red-Black Tree Balancing", "Data Structures & Algo", .medium, 2, 60, "Write rotation algorithms and test with benchmark cases"),
                ("Eulerian Path & Graph Theory Problem Set", "Mathematics for Computing", .medium, 3, 50, "Solve exercises 4.1 through 4.8 in discrete math text"),
                ("Train Core ML Study Duration Classifier", "Artificial Intelligence", .high, 2, 60, "Test regression baseline with historical student session logs"),
                ("Conduct Heuristic Evaluation for Mobile UI", "Human-Computer Interaction", .low, 4, 35, "Evaluate accessibility compliance according to WCAG 2.1"),
                ("Review Lecture Notes for Module Quiz", "Software Engineering", .low, 5, 25, "Chapters 3 and 4: Agile Scrum vs Kanban frameworks")
            ]
            
            for item in sampleTasks {
                let task = TaskItem(context: context)
                task.id = UUID()
                task.title = item.title
                task.subject = item.subject
                task.priority = item.priority.rawValue
                task.dueDate = calendar.date(byAdding: .day, value: item.daysFromNow, to: now)?
                    .addingTimeInterval(TimeInterval(3600 * (14 + item.daysFromNow % 5)))
                task.isCompleted = false
                task.estimatedMinutes = item.estMin
                task.createdAt = calendar.date(byAdding: .day, value: -2, to: now)
                task.notes = item.notes
            }
            
            // Add a couple already completed tasks for today
            let completed1 = TaskItem(context: context)
            completed1.id = UUID()
            completed1.title = "Read Software Engineering Sprint Backlog"
            completed1.subject = "Software Engineering"
            completed1.priority = TaskPriority.medium.rawValue
            completed1.dueDate = now
            completed1.isCompleted = true
            completed1.estimatedMinutes = 30
            completed1.createdAt = calendar.date(byAdding: .day, value: -1, to: now)
            completed1.completedAt = now.addingTimeInterval(-7200)
            completed1.notes = "Reviewed backlog user stories with team."
            
            let completed2 = TaskItem(context: context)
            completed2.id = UUID()
            completed2.title = "Weekly Reading Summary"
            completed2.subject = "Research & Dissertation"
            completed2.priority = TaskPriority.low.rawValue
            completed2.dueDate = now
            completed2.isCompleted = true
            completed2.estimatedMinutes = 25
            completed2.createdAt = calendar.date(byAdding: .day, value: -3, to: now)
            completed2.completedAt = now.addingTimeInterval(-14400)
        }
        
        // 3. Historical Study Sessions (Past 7-10 days for Swift Charts & ML Predictor)
        let sessionFetch: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        let existingSessions = (try? context.fetch(sessionFetch)) ?? []
        if existingSessions.isEmpty {
            let calendar = Calendar.current
            let now = Date()
            
            // Generate sessions across past 7 days
            let sessionBlueprints: [(dayOffset: Int, hour: Int, duration: Double, subject: String, mode: String, rating: Int16)] = [
                // Today (day 0)
                (0, 10, 45.0, "Software Engineering", "Standard", 5),
                (0, 14, 25.0, "Research & Dissertation", "Short Focus", 4),
                (0, 19, 45.0, "Software Engineering", "Standard", 5),
                
                // Yesterday (day -1)
                (-1, 9, 45.0, "Data Structures & Algo", "Standard", 4),
                (-1, 15, 60.0, "Research & Dissertation", "Deep Focus", 5),
                (-1, 19, 45.0, "Software Engineering", "Standard", 5),
                
                // Day -2
                (-2, 11, 25.0, "Mathematics for Computing", "Short Focus", 3),
                (-2, 16, 45.0, "Artificial Intelligence", "Standard", 4),
                (-2, 20, 60.0, "Software Engineering", "Deep Focus", 5),
                
                // Day -3
                (-3, 10, 60.0, "Research & Dissertation", "Deep Focus", 5),
                (-3, 15, 45.0, "Data Structures & Algo", "Standard", 4),
                (-3, 19, 45.0, "Software Engineering", "Standard", 5),
                
                // Day -4
                (-4, 14, 25.0, "Human-Computer Interaction", "Short Focus", 4),
                (-4, 18, 45.0, "Artificial Intelligence", "Standard", 5),
                (-4, 20, 25.0, "Software Engineering", "Short Focus", 4),
                
                // Day -5
                (-5, 10, 45.0, "Mathematics for Computing", "Standard", 4),
                (-5, 16, 60.0, "Research & Dissertation", "Deep Focus", 5),
                (-5, 19, 45.0, "Software Engineering", "Standard", 5),
                
                // Day -6
                (-6, 11, 45.0, "Data Structures & Algo", "Standard", 4),
                (-6, 17, 45.0, "Software Engineering", "Standard", 5),
                (-6, 19, 60.0, "Artificial Intelligence", "Deep Focus", 5)
            ]
            
            for item in sessionBlueprints {
                if let targetDate = calendar.date(byAdding: .day, value: item.dayOffset, to: now) {
                    var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
                    components.hour = item.hour
                    components.minute = 15
                    let startTime = calendar.date(from: components) ?? targetDate
                    let endTime = startTime.addingTimeInterval(item.duration * 60)
                    
                    let session = StudySession(context: context)
                    session.id = UUID()
                    session.subject = item.subject
                    session.durationMinutes = item.duration
                    session.startTime = startTime
                    session.endTime = endTime
                    session.sessionMode = item.mode
                    session.productivityRating = item.rating
                    session.wasCompleted = true
                    session.notes = "Focused study block on \(item.subject)."
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error seeding sample data: \(error)")
        }
    }
    
    // MARK: - Reset All Data
    func resetAllData(context: NSManagedObjectContext) {
        let entities = ["TaskItem", "StudySession", "UserProfile", "Item"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete entity \(entity): \(error)")
            }
        }
        
        // Re-create default profile
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.name = "Mithula"
        profile.streakCount = 1
        profile.lastStudyDate = Date()
        profile.defaultPomodoroMinutes = 25
        profile.dailyGoalHours = 3.0
        
        try? context.save()
    }
    
    // MARK: - Export Data as JSON
    func exportDataAsJSON(context: NSManagedObjectContext) -> String {
        let taskFetch: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
        let sessionFetch: NSFetchRequest<StudySession> = StudySession.fetchRequest()
        
        let tasks = (try? context.fetch(taskFetch)) ?? []
        let sessions = (try? context.fetch(sessionFetch)) ?? []
        
        let exportDict: [String: Any] = [
            "appName": "FocusFlow",
            "exportedAt": ISO8601DateFormatter().string(from: Date()),
            "tasksCount": tasks.count,
            "sessionsCount": sessions.count,
            "tasks": tasks.map { [
                "title": $0.unwrappedTitle,
                "subject": $0.unwrappedSubject,
                "priority": $0.priority ?? "Medium",
                "isCompleted": $0.isCompleted,
                "dueDate": $0.dueDate?.description ?? ""
            ] },
            "sessions": sessions.map { [
                "subject": $0.unwrappedSubject,
                "durationMinutes": $0.durationMinutes,
                "startTime": $0.startTime?.description ?? "",
                "productivityRating": $0.productivityRating,
                "sessionMode": $0.sessionMode ?? "Standard"
            ] }
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
}
