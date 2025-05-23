//
//  PulsingDot.swift
//  runwithfriends
//
//  Created by Xavier Chia PY on 23/5/25.
//

import Foundation
import SwiftUI

// Custom pulsing dot animation view
struct PulsingDot: View {
    let color: Color
    
    // Animation state
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Growing and fading outer ring
            Circle()
                .fill(color)
                .opacity(isAnimating ? 0 : 0.5)
                .frame(width: 12, height: 12)
                .scaleEffect(isAnimating ? 2.5 : 1)
                // Using easeOut animation to start fast and end slow
                .animation(
                    Animation.linear(duration: 2)
                        .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Solid center dot that never changes
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
        }
        .onAppear {
            // Short delay before starting animation to ensure view is fully rendered
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isAnimating = true
            }
        }
    }
}
