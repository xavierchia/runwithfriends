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
    
    @State private var chartMode: ChartMode = .week
    @State private var weekData: [DateSteps] = []
    @State private var dayData: [DateSteps] = []
    @State private var isLoadingWeek = false
    @State private var isLoadingDay = false
    @State private var errorMessage: String?
    
    // Cache flags to track what we've loaded
    @State private var hasLoadedWeekData = false
    @State private var hasLoadedDayData = false
    
    // Debug mode for testing with dummy data
    private let useDummyData: Bool
    
    init(useDummyData: Bool = false) {
        self.useDummyData = useDummyData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Interactive header
            StepsToggleHeader(selectedMode: $chartMode)
            
            // Chart content with loading states
            Group {
                switch chartMode {
                case .day:
                    if isLoadingDay {
                        loadingView
                    } else if dayData.isEmpty && hasLoadedDayData {
                        emptyStateView(for: "daily")
                    } else {
                        DayStepsChart(dateSteps: dayData)
                    }
                    
                case .week:
                    if isLoadingWeek {
                        loadingView
                    } else if weekData.isEmpty && hasLoadedWeekData {
                        emptyStateView(for: "weekly")
                    } else {
                        WeekStepsChart(dateSteps: weekData)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: chartMode)
            
            // Error message if any
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.quicksand(size: 12))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .background(.baseBackground)
        .onAppear {
            loadInitialData()
        }
        .onChange(of: chartMode) { _, newMode in
            loadDataForMode(newMode)
        }
    }
    
    // MARK: - Loading and Empty States
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading steps data...")
                .font(.quicksand(size: 14))
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(uiColor: .baseBackground))
    }
    
    private func emptyStateView(for dataType: String) -> some View {
        VStack {
            Image(systemName: "figure.walk")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No \(dataType) data available")
                .font(.quicksand(size: 16))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            Text("Start walking to see your progress!")
                .font(.quicksand(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(uiColor: .baseBackground))
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        // Load data for the default mode (week)
        loadDataForMode(chartMode)
    }
    
    private func loadDataForMode(_ mode: ChartMode) {
        switch mode {
        case .week:
            loadWeekData()
        case .day:
            loadDayData()
        }
    }
    
    private func loadWeekData() {
        // Don't reload if we already have data
        guard !hasLoadedWeekData else { return }
        
        isLoadingWeek = true
        errorMessage = nil
        
        Task {
            
            var data = await GraphMachine.shared.getSteps12Weeks()
            
            if useDummyData {
                data = generateDummyWeekData()
            }
            
            await MainActor.run {
                self.weekData = data
                self.hasLoadedWeekData = true
                self.isLoadingWeek = false
            }
        }
    }
    
    private func loadDayData() {
        // Don't reload if we already have data
        guard !hasLoadedDayData else { return }
        
        isLoadingDay = true
        errorMessage = nil
        
        Task {
            var data = await StepCounter.shared.getStepsForDateRange(.rollingWeek)
            
            if useDummyData {
                data = generateDummyDayData()
            }
            
            await MainActor.run {
                self.dayData = data
                self.hasLoadedDayData = true
                self.isLoadingDay = false
            }
        }
    }
    
    // MARK: - Public Methods for Refresh
    
    func refreshData() {
        // Clear cache flags and reload current mode
        hasLoadedWeekData = false
        hasLoadedDayData = false
        weekData = []
        dayData = []
        loadDataForMode(chartMode)
    }
    
    func refreshCurrentMode() {
        // Refresh only the current mode
        switch chartMode {
        case .week:
            hasLoadedWeekData = false
            weekData = []
            loadWeekData()
        case .day:
            hasLoadedDayData = false
            dayData = []
            loadDayData()
        }
    }
    
    // MARK: - Dummy Data Generation
    
    private func generateDummyWeekData() -> [DateSteps] {
        let calendar = Calendar.current
        let baseSteps = [45000, 52000, 38000, 65000, 71000, 42000, 58000, 48000, 55000, 39000, 62000, 120000]
        
        return baseSteps.enumerated().map { index, steps in
            let date = calendar.date(byAdding: .weekOfYear, value: -11 + index, to: Date()) ?? Date()
            return DateSteps(date: date, steps: Double(steps))
        }
    }
    
    private func generateDummyDayData() -> [DateSteps] {
        let calendar = Calendar.current
        let baseSteps = [8500, 12200, 6700, 14800, 11300, 9600, 13100]
        
        return baseSteps.enumerated().map { index, steps in
            let date = calendar.date(byAdding: .day, value: -6 + index, to: Date()) ?? Date()
            let startOfDay = calendar.startOfDay(for: date)
            return DateSteps(date: startOfDay, steps: Double(steps))
        }
    }
}
