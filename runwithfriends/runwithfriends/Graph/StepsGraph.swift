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
    
    @State private var chartMode: ChartMode
    @State private var weekData: [DateSteps] = []
    @State private var dayData: [DateSteps] = []
    
    // Debug mode for testing with dummy data
    private let useDummyData: Bool
    
    init(useDummyData: Bool = false) {
        self.useDummyData = useDummyData
        
        // Initialize chartMode from UserDefaults
        if let defaults = PeaDefaults.shared,
           let savedModeString = defaults.string(forKey: UserDefaultsKey.graphChartMode),
           let savedModeChart = ChartMode(rawValue: savedModeString) {
            _chartMode = State(initialValue: savedModeChart)
        } else {
            _chartMode = State(initialValue: .week)
        }
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
                UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.gray)
            }
        }
        .background(.baseBackground)
        .onAppear {
            loadInitialData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            loadInitialData()
        }
        .onChange(of: chartMode) { _, newMode in
            saveChartMode(newMode)
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
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadInitialData() {
        switch chartMode {
        case ChartMode.week:
            loadWeekData()
            loadDayData()
        case ChartMode.day:
            loadDayData()
            loadWeekData()
        }
    }
    
    private func loadWeekData() {
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
        Task {
            var data = await StepCounter.shared.getStepsForDateRange(.currentWeek)
            
            if useDummyData {
                data = generateDummyDayData()
            }
            
            await MainActor.run {
                self.dayData = data
            }
        }
    }
    
    // MARK: - Dummy Data Generation
    
    private func generateDummyWeekData() -> [DateSteps] {
        let calendar = Calendar.current
        let baseSteps = [45000, 52000, 20000, 120000, 71000, 42000, 58000, 48000, 55000, 39000, 62000, 80000]
        
        return baseSteps.enumerated().map { index, steps in
            let date = calendar.date(byAdding: .weekOfYear, value: -11 + index, to: Date()) ?? Date()
            return DateSteps(date: date, steps: Double(steps))
        }
    }
    
    private func generateDummyDayData() -> [DateSteps] {
        let calendar = Calendar.current
        let baseSteps = [8500, 12200, 6700, 14800, 11300, 9600, 50000]
        
        return baseSteps.enumerated().map { index, steps in
            let date = calendar.date(byAdding: .day, value: -6 + index, to: Date()) ?? Date()
            let startOfDay = calendar.startOfDay(for: date)
            return DateSteps(date: startOfDay, steps: Double(steps))
        }
    }
    
    // MARK: - UserDefaults Persistence
    
    private func saveChartMode(_ mode: ChartMode) {
        PeaDefaults.shared?.set(mode.rawValue, forKey: UserDefaultsKey.graphChartMode)
    }
}
