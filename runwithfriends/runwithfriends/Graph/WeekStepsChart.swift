//
//  WeekStepsChart.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 26/5/25.
//

import Foundation
import SwiftUI
import Charts
import SharedCode

struct WeekStepsChart: View {
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
    
    private func didAchieveMarathon(for item: DateSteps) -> Bool {
        let week = weekNumber(from: item.date)
        if let marathon = MarathonData.marathonsByWeekOfYear[week] {
            return item.steps >= Double(marathon.steps)
        } else {
            // Fallback: if no marathon data, use 60k steps threshold
            return item.steps >= 60000
        }
    }
    
    var body: some View {
        Chart {
            // Base chart content for previous weeks - lines only
            ForEach(dateSteps.dropLast()) { item in
                LineMark(
                    x: .value("Week", weekNumber(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(.separate)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 10]))
            }
            
            // Point marks for previous weeks with conditional styling
            ForEach(dateSteps.dropLast()) { item in
                if didAchieveMarathon(for: item) {
                    // Solid moss circle for marathon complete
                    PointMark(
                        x: .value("Week", weekNumber(from: item.date)),
                        y: .value("Steps", item.steps)
                    )
                    .foregroundStyle(by: .value("Series", "Marathon complete"))
                    .symbolSize(100)
                } else {
                    // Hollow moss circle for just walking
                    PointMark(
                        x: .value("Week", weekNumber(from: item.date)),
                        y: .value("Steps", item.steps)
                    )
                    .foregroundStyle(by: .value("Series", "Just walking"))
                    .symbolSize(100)
                    .annotation(position: .overlay) {
                        ZStack {
                            // Background circle to hide line
                            Circle()
                                .fill(Color(uiColor: .baseBackground))
                                .frame(width: 10, height: 10)
                            // Hollow stroke
                            Circle()
                                .stroke(.moss, lineWidth: 3)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                
                // Step count annotation
                PointMark(
                    x: .value("Week", weekNumber(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(.clear)
                .annotation(position: .top, spacing: 10) {
                    Text("\(String(format: "%.0f", (item.steps / 1000)))k")
                        .font(.quicksand(size: 12))
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
                
                LineMark(
                    x: .value("Week", weekNumber(from: previousItem.date)),
                    y: .value("Steps", previousItem.steps)
                )
                .foregroundStyle(.separate)
                
                LineMark(
                    x: .value("Week", weekNumber(from: lastItem.date)),
                    y: .value("Steps", lastItem.steps)
                )
                .foregroundStyle(.separate)
            }
            
            // Custom overlay for the pulsing dot at the last item's position
            if let lastItem = dateSteps.last {
                PointMark(
                    x: .value("Week", weekNumber(from: lastItem.date)),
                    y: .value("Steps", lastItem.steps)
                )
                .foregroundStyle(by: .value("Series", "This Week"))
                .symbolSize(0) // Make invisible but contribute to legend
                .annotation(position: .top, spacing: 10) {
                    Text("\(String(format: "%.0f", (lastItem.steps / 1000)))k")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                }
                .annotation(position: .overlay) {
                    PulsingDot(color: Color("AccentColor"))
                }
            }
        }
        .chartForegroundStyleScale([
            "Marathon complete": .moss,
            "Just walking": .clear, // Make the legend symbol transparent
            "This Week": Color("AccentColor")
        ])
        .chartSymbolScale([
            "Marathon complete": .circle,
            "Just walking": .circle
        ])
        .chartXScale(domain: minWeek...maxWeek)
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let week = value.as(Int.self) {
                        Text("\(week)")
                            .font(.quicksand(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let steps = value.as(Double.self) {
                        Text("\(String(format: "%.0f", steps / 1000))k")
                        .font(.quicksand(size: 12))
                    }
                }
            }
        }
        .chartLegend(position: .bottom, alignment: .center) {
            HStack {
                // Marathon complete legend
                HStack(spacing: 4) {
                    Circle()
                        .fill(.moss)
                        .frame(width: 8, height: 8)
                    Text("Marathon complete")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
                
                Spacer().frame(width: 16)
                
                // Just walking legend
                HStack(spacing: 4) {
                    Circle()
                        .stroke(.moss, lineWidth: 2)
                        .frame(width: 8, height: 8)
                    Text("Just walking")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
                
                Spacer().frame(width: 16)
                
                // This week legend
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 8, height: 8)
                    Text("This Week")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
            }
        }
        .chartBackground { _ in
            Color(uiColor: .baseBackground)
        }
    }
}
