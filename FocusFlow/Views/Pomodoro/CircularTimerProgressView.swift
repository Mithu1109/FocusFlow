//
//  CircularTimerProgressView.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import SwiftUI

struct CircularTimerProgressView: View {
    @Environment(\.colorScheme) private var colorScheme
    let progress: Double
    let formattedTime: String
    let timerState: TimerState
    let modeColor: Color
    
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Background ambient pulse glow when running
            if timerState == .running {
                Circle()
                    .fill(modeColor.opacity(colorScheme == .dark ? 0.18 : 0.12))
                    .frame(width: 275, height: 275)
                    .scaleEffect(pulseScale)
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 1.6)
                                .repeatForever(autoreverses: true)
                        ) {
                            pulseScale = 1.08
                        }
                    }
                    .onDisappear {
                        pulseScale = 1.0
                    }
            }
            
            // Track circle
            Circle()
                .stroke(
                    modeColor.opacity(colorScheme == .dark ? 0.22 : 0.12),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 250, height: 250)
            
            // Animated Progress Circle
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [modeColor, modeColor.opacity(0.8), FocusFlowTheme.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: progress)
                .shadow(color: modeColor.opacity(0.4), radius: 8, x: 0, y: 0)
            
            // Inner Center Display
            VStack(spacing: 8) {
                // Status Pill
                HStack(spacing: 5) {
                    Circle()
                        .fill(stateDotColor)
                        .frame(width: 7, height: 7)
                    
                    Text(stateText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(stateDotColor)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(stateDotColor.opacity(colorScheme == .dark ? 0.22 : 0.12))
                .clipShape(Capsule())
                
                // Digital Countdown Time
                Text(formattedTime)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(FocusFlowTheme.text(for: colorScheme))
                    .contentTransition(.numericText())
                
                // Subtitle
                Text(timerState == .running ? "Stay with the flow" : "Ready when you are")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(FocusFlowTheme.textSecondary(for: colorScheme))
            }
        }
        .frame(height: 290)
    }
    
    private var stateDotColor: Color {
        switch timerState {
        case .idle: return FocusFlowTheme.textSecondary(for: colorScheme)
        case .running: return FocusFlowTheme.success
        case .paused: return FocusFlowTheme.warning
        case .completed: return FocusFlowTheme.primary
        }
    }
    
    private var stateText: String {
        switch timerState {
        case .idle: return "READY"
        case .running: return "FOCUSING"
        case .paused: return "PAUSED"
        case .completed: return "FINISHED"
        }
    }
}
