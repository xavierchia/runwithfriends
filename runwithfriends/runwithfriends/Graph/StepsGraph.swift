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
    
    // Debug mode for testing with dummy data
    private let useDummyData: Bool
    
    init(useDummyData: Bool = false) {
        self.useDummyData = useDummyData
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Interactive header
            StepsToggleHeader(selectedMode: $chartMode)
            
            // Swipeable chart content with page dots
            TabView(selection: $chartMode) {
                // Day view
                VStack {
                    if dayData.isEmpty {
                        loadingView
                    } else {
                        DayStepsChart(dateSteps: dayData)
                            .padding(.top, 10)
                            .padding(.bottom, 50)
                    }
                }
                .tag(ChartMode.day)
                
                // Week view
                VStack {
                    if weekData.isEmpty {
                        loadingView
                    } else {
                        WeekStepsChart(dateSteps: weekData)
                            .padding(.top, 10)
                            .padding(.bottom, 50)
                    }
                }
                .tag(ChartMode.week)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                // Set custom page indicator colors
                UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.baseText)
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.secondary)
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
    
    private var loadingView: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text("Loading steps data...")
                    .font(.quicksand(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        // Load data for the default mode (week)
        loadDataForMode(chartMode)
        loadDataForMode(.day)
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
        guard weekData.isEmpty else { return }
        
        Task {
            var data = await GraphMachine.shared.getSteps12Weeks()
            
            if useDummyData {
                data = generateDummyWeekData()
            }
            
            await MainActor.run {
                self.weekData = data
            }
        }
    }
    
    private func loadDayData() {
        // Don't reload if we already have data
        guard dayData.isEmpty else { return }
        
        Task {
            var data = await StepCounter.shared.getStepsForDateRange(.rollingWeek)
            
            if useDummyData {
                data = generateDummyDayData()
            }
            
            await MainActor.run {
                self.dayData = data
            }
        }
    }
    
    // MARK: - Public Methods for Refresh
    
    func refreshData() {
        // Clear data and reload current mode
        weekData = []
        dayData = []
        loadDataForMode(chartMode)
    }
    
    func refreshCurrentMode() {
        // Refresh only the current mode
        switch chartMode {
        case .week:
            weekData = []
            loadWeekData()
        case .day:
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
