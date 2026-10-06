//
//  TaskRowView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct TaskRowView: View {
    @ObservedObject var task: TaskItem
    let onToggleComplete: () -> Void
    var onDelete: (() -> Void)? = nil
    var onSelectForFocus: (() -> Void)? = nil
    
    @State private var dragOffset: CGFloat = 0
    @State private var isSwiping: Bool = false
    
    private let completionThreshold: CGFloat = 85.0
    private let actionMenuWidth: CGFloat = 100.0
    
    var body: some View {
        ZStack {
            // Background Action Reveals
            actionBackground
            
            // Foreground Card
            cardContent
                .offset(x: dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 15, coordinateSpace: .local)
                        .onChanged { value in
                            // Only allow horizontal translation
                            if abs(value.translation.width) > abs(value.translation.height) {
                                isSwiping = true
                                // Resistance when dragging beyond limits
                                if value.translation.width > 0 {
                                    dragOffset = min(value.translation.width, 130)
                                } else {
                                    dragOffset = max(value.translation.width, -120)
                                }
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                if value.translation.width > completionThreshold {
                                    // Trigger swipe to complete
                                    HapticManager.shared.success()
                                    onToggleComplete()
                                    dragOffset = 0
                                } else if value.translation.width < -70 {
                                    // Reveal delete / action buttons
                                    dragOffset = -actionMenuWidth
                                } else {
                                    dragOffset = 0
                                }
                                isSwiping = false
                            }
                        }
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    // MARK: - Background Reveal Layer
    private var actionBackground: some View {
        HStack(spacing: 0) {
            // Left Reveal: Swipe right to Complete
            HStack {
                Image(systemName: task.isCompleted ? "arrow.uturn.backward.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text(task.isCompleted ? "Unmark" : "Complete")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.leading, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(task.isCompleted ? Color.orange : FocusFlowTheme.success)
            .opacity(dragOffset > 10 ? min(Double(dragOffset) / 50.0, 1.0) : 0)
            
            // Right Reveal: Swipe left to Delete or Focus
            HStack(spacing: 12) {
                Spacer()
                
                if let onDelete = onDelete {
                    Button(action: {
                        withAnimation {
                            dragOffset = 0
                            onDelete()
                        }
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("Delete")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(width: 55, height: 55)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.trailing, 10)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.red.opacity(0.15))
            .opacity(dragOffset < -10 ? min(Double(-dragOffset) / 50.0, 1.0) : 0)
        }
    }
    
    // MARK: - Foreground Card Content
    private var cardContent: some View {
        HStack(alignment: .center, spacing: 14) {
            // Interactive Checkbox
            Button(action: onToggleComplete) {
                ZStack {
                    Circle()
                        .stroke(
                            task.isCompleted ? FocusFlowTheme.success : Color.gray.opacity(0.35),
                            lineWidth: 2
                        )
                        .frame(width: 26, height: 26)
                    
                    if task.isCompleted {
                        Circle()
                            .fill(FocusFlowTheme.success)
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task Info
            VStack(alignment: .leading, spacing: 6) {
                // Title
                Text(task.unwrappedTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .lineLimit(2)
                
                // Badges row: Subject + Priority
                HStack(spacing: 6) {
                    // Subject Chip
                    HStack(spacing: 4) {
                        Circle()
                            .fill(task.subjectModule.color)
                            .frame(width: 7, height: 7)
                        Text(task.unwrappedSubject)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(task.subjectModule.color.opacity(0.12))
                    .clipShape(Capsule())
                    
                    // Priority Pill
                    HStack(spacing: 3) {
                        Image(systemName: task.taskPriority.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(task.taskPriority.title)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(task.taskPriority.color)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(task.taskPriority.color.opacity(0.12))
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
                }
                
                // Due Date Badge
                dueDateBadge
            }
            
            // Quick Focus Action (if pending)
            if !task.isCompleted, let onSelectForFocus = onSelectForFocus {
                Button(action: onSelectForFocus) {
                    Image(systemName: "timer")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(FocusFlowTheme.primary)
                        .frame(width: 32, height: 32)
                        .background(FocusFlowTheme.primary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                .help("Focus on this task")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .focusFlowCard(cornerRadius: 14)
    }
    
    // MARK: - Due Date Badge
    private var dueDateBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : (task.isOverdue ? "exclamationmark.circle.fill" : "calendar"))
                .font(.system(size: 10, weight: task.isOverdue ? .bold : .medium))
            
            Text(task.relativeDueString)
                .font(.system(size: 11, weight: task.isOverdue ? .semibold : .medium))
                .lineLimit(1)
        }
        .foregroundColor(
            task.isCompleted ? FocusFlowTheme.success :
            (task.isOverdue ? FocusFlowTheme.highPriority : .secondary)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            task.isCompleted ? FocusFlowTheme.success.opacity(0.12) :
            (task.isOverdue ? FocusFlowTheme.highPriority.opacity(0.12) : Color.secondary.opacity(0.08))
        )
        .clipShape(Capsule())
    }
}
