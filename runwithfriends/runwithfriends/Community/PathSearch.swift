import Foundation
import MapKit

/// This struct provides an efficient way to find coordinates on a path based on step count
struct PathSearch {
    
    /// Finds the closest coordinate on a path that corresponds to a given step count using binary search
    /// - Parameters:
    ///   - stepCoordinates: Array of step coordinates with cumulative step information
    ///   - targetSteps: The number of steps to find position for
    /// - Returns: The coordinate that corresponds to the target step count
    static func findCoordinateForSteps(in stepCoordinates: [StepCoordinate], targetSteps: Double) -> CLLocationCoordinate2D? {
        guard !stepCoordinates.isEmpty else { return nil }
        
        // Handle edge cases
        if targetSteps <= stepCoordinates[0].steps {
            return stepCoordinates[0].coordinate
        }
        
        if targetSteps >= stepCoordinates.last!.steps {
            return stepCoordinates.last!.coordinate
        }
        
        // Binary search to find the closest position
        var left = 0
        var right = stepCoordinates.count - 1
        
        while left <= right {
            let mid = left + (right - left) / 2
            
            if stepCoordinates[mid].steps == targetSteps {
                // Exact match found
                return stepCoordinates[mid].coordinate
            } else if stepCoordinates[mid].steps < targetSteps {
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        // Now 'left' points to the smallest element greater than target
        // and 'right' points to the largest element smaller than target
        
        // Find which one is closer
        if right < 0 {
            return stepCoordinates[0].coordinate
        } else if left >= stepCoordinates.count {
            return stepCoordinates.last!.coordinate
        } else {
            // Choose the closer point
            let diffRight = abs(stepCoordinates[left].steps - targetSteps)
            let diffLeft = abs(targetSteps - stepCoordinates[right].steps)
            
            if diffRight < diffLeft {
                return stepCoordinates[left].coordinate
            } else {
                return stepCoordinates[right].coordinate
            }
        }
    }
}
