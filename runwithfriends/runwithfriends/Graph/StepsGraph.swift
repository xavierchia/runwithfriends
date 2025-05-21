//
//  StepsGraph.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 20/5/25.
//

import Foundation
import SwiftUI
import Charts

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
        Chart(dateSteps) { item in
            let isLast = weekNumber(from: item.date) == maxWeek
            
            LineMark(
                x: .value("Week", weekNumber(from: item.date)),
                y: .value("Steps", item.steps)
            )
            .foregroundStyle(.moss)
            
            PointMark(
                x: .value("Week", weekNumber(from: item.date)),
                y: .value("Steps", item.steps)
            )
            .foregroundStyle(.moss)
            .annotation(position: isLast ? .topLeading : .top) {
                if isLast {
                    Text("This week:\n\(String(format: "%.0f", (item.steps / 1000)))k")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.8))
                        )
                } else {
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
        }
        .chartXScale(domain: minWeek...maxWeek)
        .chartXAxisLabel(position: .bottom, alignment: .center) {
            Text("Week")
                .foregroundColor(.gray)
        }
        
        .chartYAxisLabel {
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
        
        .chartBackground { _ in
            Color(uiColor: .baseBackground)
        }
        //        .background(Color(uiColor: .baseBackground))
    }
}
