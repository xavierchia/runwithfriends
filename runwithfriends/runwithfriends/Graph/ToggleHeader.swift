//
//  ToggleHeader.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 23/5/25.
//

import Foundation
import SwiftUI

// Convenience view specifically for Steps
struct StepsToggleHeader: View {
    @Binding var selectedMode: ChartMode
    
    var body: some View {
        ToggleHeader(
            prefix: "Your steps by",
            options: [.day, .week],
            selectedOption: $selectedMode
        )
    }
}

struct ToggleHeader: View {
    let prefix: String
    let options: [ChartMode]
    @Binding var selectedOption: ChartMode
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Static prefix text
            Text(prefix)
                .font(.quicksandMedium(size: 18))
                .foregroundColor(.baseText)
            
            Spacer()
            
            // Segmented control
            Picker("", selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 130)  // Adjust this width as needed
        }
    }
}

