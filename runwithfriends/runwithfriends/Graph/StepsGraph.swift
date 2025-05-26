//
//  StepsGraph.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 20/5/25.
//

import Foundation
import SwiftUI
import Charts
import SharedCode

enum ChartMode: String, CaseIterable {
    case day = "day"
    case week = "week"
}

struct StepsGraph: View {
    
    let dateSteps: [DateSteps]
    @State private var chartMode: ChartMode = .week
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Interactive header
            StepsToggleHeader(selectedMode: $chartMode)
            
            // Chart - switch between day and week views
            Group {
                switch chartMode {
                case .day:
                    DayStepsChart(dateSteps: dateSteps)
                case .week:
                    WeekStepsChart(dateSteps: dateSteps)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: chartMode)
        }
        .background(.baseBackground)
    }
}
