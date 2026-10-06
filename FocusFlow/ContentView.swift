//
//  ContentView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        MainTabView()
            .onAppear {
                // Ensure initial university sample data is present so the app is immediately full of life
                let taskFetch: NSFetchRequest<TaskItem> = TaskItem.fetchRequest()
                let count = (try? viewContext.count(for: taskFetch)) ?? 0
                if count == 0 {
                    PersistenceController.shared.seedUniversitySampleData(context: viewContext)
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
