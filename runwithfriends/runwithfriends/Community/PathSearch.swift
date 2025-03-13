import Foundation
import MapKit

// This struct provides an efficient way to find coordinates on a path based on step count
struct PathSearch {
    
    /// Finds the exact coordinate on a path that corresponds to a given step count using binary search
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
                // Check if we're between this and the next point
                if mid + 1 < stepCoordinates.count && stepCoordinates[mid + 1].steps > targetSteps {
                    // Use the interpolate helper function
                    return interpolate(from: stepCoordinates[mid], to: stepCoordinates[mid + 1], targetSteps: targetSteps)
                }
                left = mid + 1
            } else {
                right = mid - 1
            }
        }
        
        // If we didn't find an exact interpolation point, use the closest index
        return left < stepCoordinates.count ? stepCoordinates[left].coordinate : stepCoordinates.last!.coordinate
    }
    
    // Private helper function to interpolate between two coordinates
    private static func interpolate(from start: StepCoordinate, to end: StepCoordinate, targetSteps: Double) -> CLLocationCoordinate2D {
        // Calculate ratio for interpolation (0.0 to 1.0)
        let totalSteps = end.steps - start.steps
        let stepsFromStart = targetSteps - start.steps
        let ratio = Double(stepsFromStart) / Double(totalSteps)
        
        // Interpolate the coordinate
        let lat = start.coordinate.latitude + (end.coordinate.latitude - start.coordinate.latitude) * ratio
        let lon = start.coordinate.longitude + (end.coordinate.longitude - start.coordinate.longitude) * ratio
        
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}
