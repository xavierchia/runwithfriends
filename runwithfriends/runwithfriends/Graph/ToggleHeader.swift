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
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            // Static prefix text
            Text(prefix)
                .font(.quicksandMedium(size: 18))
                .foregroundColor(.baseText)
            
            Spacer()
            
            // Toggle options
            HStack(spacing: 4) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    // Add separator between options
                    if index > 0 {
                        Text("or")
                            .font(.quicksandMedium(size: 18))
                            .foregroundColor(.baseText)
                    }
                    
                    // Toggle option
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedOption = option
                        }
                    }) {
                            Text(option.rawValue)
                            .font(selectedOption == option ? .quicksandBold(size: 18) : .quicksandMedium(size: 18))
                                .foregroundColor(selectedOption == option ? .baseText : .baseText)

                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .fixedSize()
        }
    }
}

