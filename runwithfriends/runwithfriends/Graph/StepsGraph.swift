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
        Chart(dateSteps) { dateSteps in
            LineMark(
                x: .value("Week", weekNumber(from: dateSteps.date)),
                y: .value("Steps", dateSteps.steps)
            )
            .foregroundStyle(.moss)
            
            PointMark(
                x: .value("Week", weekNumber(from: dateSteps.date)),
                y: .value("Steps", dateSteps.steps)
            )
            .foregroundStyle(.moss)
            .annotation(position: .top) {
                Text("\(String(format: "%.0f", (dateSteps.steps / 1000)))k")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.8))
                    )
            }
        }
        .chartXScale(domain: minWeek...maxWeek)
        .chartXAxisLabel {
            Text("Week")
                .foregroundColor(.gray)
        }
        
        .chartYAxisLabel {
            Text("Steps")
                .foregroundColor(.gray)
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        
        .chartBackground { _ in
            Color(uiColor: .baseBackground)
        }
        //        .background(Color(uiColor: .baseBackground))
    }
}
