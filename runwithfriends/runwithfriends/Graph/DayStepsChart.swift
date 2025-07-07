//
//  DayStepsChart.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 26/5/25.
//

import Foundation
import SwiftUI
import Charts
import SharedCode

struct DayStepsChart: View {
    let dateSteps: [DateSteps]
    
    // Get current marathon for completion threshold
    private var currentMarathon: Marathon {
        MarathonData.getCurrentMarathon()
    }
    
    // Add fake data point for spacing
    private var chartData: [DateSteps] {
        guard let lastItem = sortedDateSteps.last else { return sortedDateSteps }
        
        let calendar = Calendar.current
        let fakeDate = calendar.date(byAdding: .day, value: 1, to: lastItem.date) ?? lastItem.date
        let fakeDataPoint = DateSteps(date: fakeDate, steps: lastItem.steps) // Use same steps as last real point
        
        return sortedDateSteps + [fakeDataPoint]
    }
    
    private var sortedDateSteps: [DateSteps] {
        dateSteps.sorted { $0.date < $1.date }
    }
    
    private var cumulativeSteps: [(date: Date, dailySteps: Double, cumulativeSteps: Double)] {
        var cumulative = 0.0
        return sortedDateSteps.map { dateStep in
            cumulative += dateStep.steps
            return (date: dateStep.date, dailySteps: dateStep.steps, cumulativeSteps: cumulative)
        }
    }
    
    private func dayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E" // Mon, Tue, Wed, etc.
        return formatter
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        Chart {
            // Half marathon threshold line (always shown)
            RuleMark(
                y: .value("Half Marathon Threshold", Double(currentMarathon.steps) / 2)
            )
            .foregroundStyle(.brightPumpkin)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 10]))
            .annotation(position: .top, alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Half marathon")
                    Text("\(String(format: "%.0f", Double(currentMarathon.steps) / 2000))k")
                }
                .font(.quicksand(size: 12))
                .foregroundColor(.pumpkin)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.8))
                        .stroke(.brightPumpkin, lineWidth: 1)
                )
                .offset(x: 5)
            }
            // Show full marathon rulemark only if half marathon exceeded
            if let lastCumulative = cumulativeSteps.last?.cumulativeSteps,
               lastCumulative > Double(currentMarathon.steps) / 2 {
                RuleMark(
                    y: .value("Marathon Threshold", Double(currentMarathon.steps))
                )
                .foregroundStyle(.brightPumpkin)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 10]))
                .annotation(position: .top, alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Full marathon")
                        Text("\(String(format: "%.0f", Double(currentMarathon.steps) / 1000))k")
                    }
                    .font(.quicksand(size: 12))
                    .foregroundColor(.pumpkin)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.8))
                            .stroke(.brightPumpkin, lineWidth: 1)
                    )
                    .offset(x: 5)
                }
            }
            
            // Base chart content for previous days - lines only (exclude fake point)
            ForEach(cumulativeSteps.filter { !isToday($0.date) }, id: \.date) { item in
                LineMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.cumulativeSteps)
                )
                .foregroundStyle(.separate)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 10]))
            }
            
            // Point marks for previous days (exclude fake point)
            ForEach(cumulativeSteps.filter { !isToday($0.date) }, id: \.date) { item in
                PointMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.cumulativeSteps)
                )
                .foregroundStyle(by: .value("Series", "Previous days"))
                .symbolSize(100)
                
                // Step count annotation
                PointMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.cumulativeSteps)
                )
                .foregroundStyle(.clear)
                .annotation(position: .top, spacing: 10) {
                    VStack(spacing: 2) {
                        Text("\(String(format: "%.0f", (item.cumulativeSteps / 1000)))k")
                            .font(.quicksand(size: 12))
                            .foregroundColor(.secondaryText)
                        Text("(+\(String(format: "%.0f", (item.dailySteps / 1000)))k)")
                            .font(.quicksand(size: 10))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.8))
                    )
                }
            }
            
            // Add line connecting to today if there are previous days - only use real data
            if let todayItem = cumulativeSteps.first(where: { isToday($0.date) }),
               let previousItem = cumulativeSteps.filter({ !isToday($0.date) }).last {
                
                LineMark(
                    x: .value("Day", dayFormatter().string(from: previousItem.date)),
                    y: .value("Steps", previousItem.cumulativeSteps)
                )
                .foregroundStyle(.separate)
                
                LineMark(
                    x: .value("Day", dayFormatter().string(from: todayItem.date)),
                    y: .value("Steps", todayItem.cumulativeSteps)
                )
                .foregroundStyle(.separate)
            }
            
            // Custom overlay for the pulsing dot at today's position
            if let todayItem = cumulativeSteps.first(where: { isToday($0.date) }) {
                PointMark(
                    x: .value("Day", dayFormatter().string(from: todayItem.date)),
                    y: .value("Steps", todayItem.cumulativeSteps)
                )
                .foregroundStyle(by: .value("Series", "Today"))
                .symbolSize(0) // Make invisible but contribute to legend
                .annotation(position: .top, spacing: 10) {
                    VStack(spacing: 2) {
                        Text("\(String(format: "%.0f", (todayItem.cumulativeSteps / 1000)))k")
                            .font(.quicksand(size: 12))
                            .foregroundColor(.secondaryText)
                        Text("(+\(String(format: "%.0f", (todayItem.dailySteps / 1000)))k)")
                            .font(.quicksand(size: 10))
                            .foregroundColor(.secondaryText)
                    }
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
            
            // Add invisible fake data point to extend chart bounds
            if let lastReal = sortedDateSteps.last,
               let fakePoint = chartData.last,
               fakePoint.date != lastReal.date {
                let lastCumulative = cumulativeSteps.last?.cumulativeSteps ?? 0
                PointMark(
                    x: .value("Day", dayFormatter().string(from: fakePoint.date)),
                    y: .value("Steps", lastCumulative)
                )
                .foregroundStyle(.clear)
                .symbolSize(0)
            }
        }
        .chartForegroundStyleScale([
            "Previous days": .moss,
            "Today": Color("AccentColor")
        ])
        .chartSymbolScale([
            "Previous days": .circle
        ])
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
                            .font(.quicksand(size: 12))
                            .foregroundColor(.secondaryText)
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
                // Previous days legend
                HStack(spacing: 4) {
                    Circle()
                        .fill(.moss)
                        .frame(width: 8, height: 8)
                    Text("Previous days")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
                
                Spacer().frame(width: 16)
                
                // Today legend
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color("AccentColor"))
                        .frame(width: 8, height: 8)
                    Text("Today")
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
