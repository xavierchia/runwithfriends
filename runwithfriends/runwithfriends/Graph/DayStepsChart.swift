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
    
    private func didAchieveTarget(for item: DateSteps) -> Bool {
        // For daily view, let's use a simpler target like 10k steps
        return item.steps >= 10000
    }
    
    var body: some View {
        Chart {
            ForEach(sortedDateSteps) { item in
                BarMark(
                    x: .value("Day", dayFormatter().string(from: item.date)),
                    y: .value("Steps", item.steps)
                )
                .foregroundStyle(isToday(item.date) ? Color("AccentColor") : (didAchieveTarget(for: item) ? .moss : .gray.opacity(0.6)))
                .cornerRadius(4)
                .annotation(position: .top, spacing: 4) {
                    Text("\(String(format: "%.0f", (item.steps / 1000)))k")
                        .font(.quicksand(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0))
                AxisTick(stroke: StrokeStyle(lineWidth: 0))
                AxisValueLabel {
                    if let day = value.as(String.self) {
                        Text(day)
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
        .chartBackground { _ in
            Color(uiColor: .baseBackground)
        }
        .overlay(alignment: .bottom) {
            // Custom legend for day view
            HStack {
                // Target achieved legend
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.moss)
                        .frame(width: 12, height: 8)
                    Text("Target hit (10k+)")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
                
                Spacer().frame(width: 16)
                
                // Today legend
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color("AccentColor"))
                        .frame(width: 12, height: 8)
                    Text("Today")
                        .font(.quicksand(size: 12))
                        .foregroundColor(.baseText)
                }
            }
            .padding(.top, 20)
        }
    }
}
