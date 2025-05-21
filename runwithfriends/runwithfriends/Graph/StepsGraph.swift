//
//  StepsGraph.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 20/5/25.
//

import Foundation
import SwiftUI
import Charts

import Foundation
import SwiftUI
import Charts

// Custom pulsing dot animation view
struct PulsingDot: View {
    let color: Color
    
    // Animation state
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Growing and fading outer ring
            Circle()
                .fill(color)
                .opacity(isAnimating ? 0 : 0.5)
                .frame(width: 10, height: 10)
                .scaleEffect(isAnimating ? 4 : 1)
                // Using easeOut animation to start fast and end slow
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Solid center dot that never changes
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        }
        .onAppear {
            // Short delay before starting animation to ensure view is fully rendered
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isAnimating = true
            }
        }
    }
}

struct StepsGraph: View {
    
    let dateSteps: [DateSteps]
    
    private func weekNumber(from date: Date) -> Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 2 corresponds to Monday
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        return weekOfYear
    }
    
    private var minWeek: Int {
        dateSteps.map { weekNumber(from: $0.date) }.min() ?? 0
    }
    
    private var maxWeek: Int {
        dateSteps.map { weekNumber(from: $0.date) }.max() ?? 0
    }
    
    var body: some View {
        Chart {
            // Base chart content for previous weeks
            ForEach(dateSteps.dropLast()) { item in
                LineMark(
                    x: .value("Week", weekNumber(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(by: .value("Series", "Previous Weeks"))
                
                PointMark(
                    x: .value("Week", weekNumber(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(by: .value("Series", "Previous Weeks"))
                .annotation(position: .top) {
                    Text("\(String(format: "%.0f", (item.steps / 1000)))k")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                }
            }
            
            // Add line for the current week (connecting to previous point)
            if let lastItem = dateSteps.last, dateSteps.count > 1 {
                let previousItem = dateSteps[dateSteps.count - 2]
                
                // Create separate lines to avoid the type error
                LineMark(
                    x: .value("Week", weekNumber(from: previousItem.date)),
                    y: .value("Steps", previousItem.steps)
                )
                .foregroundStyle(by: .value("Series", "Previous Weeks"))
                
                LineMark(
                    x: .value("Week", weekNumber(from: lastItem.date)),
                    y: .value("Steps", lastItem.steps)
                )
                .foregroundStyle(by: .value("Series", "Previous Weeks"))
            }
            
            // Custom overlay for the pulsing dot at the last item's position
            if let lastItem = dateSteps.last {
                PointMark(
                    x: .value("Week", weekNumber(from: lastItem.date)),
                    y: .value("Steps", lastItem.steps)
                )
                .foregroundStyle(.clear) // Make the default point invisible
                .annotation(position: .overlay) {
                    PulsingDot(color: Color("AccentColor"))
                }
                .annotation(position: .top) {
                    Text("\(String(format: "%.0f", (lastItem.steps / 1000)))k")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                }
            }
        }
        .chartForegroundStyleScale([
            "Previous Weeks": .moss,
            "This Week": Color("AccentColor")
        ])
        .chartXScale(domain: minWeek...maxWeek)
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text("Week")
                .foregroundColor(.gray)
        }
        .chartYAxisLabel(position: .topLeading) {
            Text("Steps")
                .foregroundColor(.gray)
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let steps = value.as(Double.self) {
                        Text("\(String(format: "%.0f", steps / 1000))k")
                    }
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .center)
        .chartBackground { _ in
            Color(uiColor: .baseBackground)
        }
    }
}
