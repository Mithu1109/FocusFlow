//
//  SessionCompletionSheet.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI
import CoreData

struct SessionCompletionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    
    @ObservedObject var viewModel: PomodoroViewModel
    
    @State private var productivityRating: Int = 5
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Celebration Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: FocusFlowTheme.success.opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text("Session Complete! 🎉")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Every minute invested in deep focus compounds your knowledge.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 10)
                    
                    // Session Stats Card
                    HStack(spacing: 16) {
                        statPill(
                            title: "Subject",
                            value: viewModel.selectedSubject,
                            icon: "book.fill",
                            color: FocusFlowTheme.primary
                        )
                        
                        statPill(
                            title: "Duration",
                            value: "\(Int(viewModel.completedDurationMinutes)) min",
                            icon: "clock.fill",
                            color: FocusFlowTheme.cyan
                        )
                    }
                    .padding(16)
                    .focusFlowCard()
                    
                    // Productivity Rating Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Rate Your Focus & Productivity")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    HapticManager.shared.selection()
                                    productivityRating = star
                                }) {
                                    Image(systemName: star <= productivityRating ? "star.fill" : "star")
                                        .font(.system(size: 32))
                                        .foregroundColor(star <= productivityRating ? Color(hex: "F59E0B") : Color.gray.opacity(0.3))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Spacer()
                            Text(ratingDescription(productivityRating))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .focusFlowCard()
                    
                    // Study Notes Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Study Notes & Key Takeaways")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        
                        TextField("What did you accomplish or learn in this session?", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(FocusFlowTheme.inputBackground(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(FocusFlowTheme.cardBorder(for: colorScheme), lineWidth: 1)
                            )
                    }
                    .padding(16)
                    .focusFlowCard()
                    
                    // Save Button
                    Button(action: {
                        viewModel.saveCompletedSession(
                            productivityRating: productivityRating,
                            notes: notes,
                            context: viewContext
                        )
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down.fill")
                            Text("Save to Study Log")
                        }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(FocusFlowTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: FocusFlowTheme.primary.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .focusFlowBackground()
            .navigationTitle("Log Study Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Discard") {
                        viewModel.resetTimerDuration()
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func statPill(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func ratingDescription(_ rating: Int) -> String {
        switch rating {
        case 5: return "Super Focused! 🚀"
        case 4: return "Productive Session 👍"
        case 3: return "Average Focus ⚡️"
        case 2: return "Distracted 🌧"
        default: return "Challenging ☕️"
        }
    }
}
