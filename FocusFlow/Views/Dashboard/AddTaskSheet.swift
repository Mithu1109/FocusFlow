//
//  AddTaskSheet.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var viewModel: DashboardViewModel
    
    @State private var title: String = ""
    @State private var selectedSubject: String = "Software Engineering"
    @State private var selectedPriority: TaskPriority = .high
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var estimatedMinutes: Int = 45
    @State private var notes: String = ""
    
    let durationOptions = [15, 25, 30, 45, 60, 90]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").font(.system(size: 12, weight: .bold))) {
                    TextField("e.g. Complete System Architecture Diagram", text: $title)
                        .font(.system(size: 15))
                    
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(SubjectModule.defaultModules) { module in
                            HStack {
                                Circle().fill(module.color).frame(width: 8, height: 8)
                                Text(module.name)
                            }
                            .tag(module.name)
                        }
                    }
                }
                
                Section(header: Text("Priority & Timeline").font(.system(size: 12, weight: .bold))) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases) { priority in
                            HStack {
                                Image(systemName: priority.icon)
                                Text(priority.title)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Est. Duration", selection: $estimatedMinutes) {
                        ForEach(durationOptions, id: \.self) { mins in
                            Text("\(mins) minutes").tag(mins)
                        }
                    }
                }
                
                Section(header: Text("Notes (Optional)").font(.system(size: 12, weight: .bold))) {
                    TextField("Specific deliverables, reading pages, or chapter references...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.system(size: 14))
                }
            }
            .navigationTitle("New Study Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Task") {
                        viewModel.addTask(
                            title: title,
                            subject: selectedSubject,
                            priority: selectedPriority,
                            dueDate: dueDate,
                            estimatedMinutes: estimatedMinutes,
                            notes: notes,
                            context: viewContext
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(FocusFlowTheme.primary)
                }
            }
        }
    }
}
