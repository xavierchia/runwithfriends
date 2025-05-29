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
            // Base chart content for previous days - lines only (exclude fake point)
            ForEach(sortedDateSteps.filter { !isToday($0.date) }) { item in
                LineMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(.separate)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 10]))
            }
            
            // Point marks for previous days (exclude fake point)
            ForEach(sortedDateSteps.filter { !isToday($0.date) }) { item in
                PointMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(by: .value("Series", "Previous days"))
                .symbolSize(100)
                
                // Step count annotation
                PointMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(.clear)
                .annotation(position: .top, spacing: 10) {
                    Text("\(String(format: "%.0f", (item.steps / 1000)))k")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.secondaryText)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                }
            }
            
            // Add line connecting to today if there are previous days - only use real data
            if let todayItem = sortedDateSteps.first(where: { isToday($0.date) }),
               let previousItem = sortedDateSteps.filter({ !isToday($0.date) }).last {
                
                LineMark(
                    x: .value("Day", dayFormatter().string(from: previousItem.date)),
                    y: .value("Steps", previousItem.steps)
                )
                .foregroundStyle(.separate)
                
                LineMark(
                    x: .value("Day", dayFormatter().string(from: todayItem.date)),
                    y: .value("Steps", todayItem.steps)
                )
                .foregroundStyle(.separate)
            }
            
            // Custom overlay for the pulsing dot at today's position
            if let todayItem = sortedDateSteps.first(where: { isToday($0.date) }) {
                PointMark(
                    x: .value("Day", dayFormatter().string(from: todayItem.date)),
                    y: .value("Steps", todayItem.steps)
                )
                .foregroundStyle(by: .value("Series", "Today"))
                .symbolSize(0) // Make invisible but contribute to legend
                .annotation(position: .top, spacing: 10) {
                    Text("\(String(format: "%.0f", (todayItem.steps / 1000)))k")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.secondaryText)
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
            if let fakePoint = chartData.last, fakePoint.date != sortedDateSteps.last?.date {
                PointMark(
                    x: .value("Day", dayFormatter().string(from: fakePoint.date)),
                    y: .value("Steps", fakePoint.steps)
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
