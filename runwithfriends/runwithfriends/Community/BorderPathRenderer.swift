//
//  BorderPathRenderer.swift
//  runwithfriends
//
//  Created by xavier chia on 22/3/24.
//

import Foundation
import MapKit

public class BorderPathRenderer: MKOverlayPathRenderer {
    
    var polyline: MKPolyline
    var color: UIColor
    var showsBorder: Bool = false
    var borderColor: UIColor = .black
    
    public init(polyline: MKPolyline, color: UIColor) {
        self.polyline = polyline
        self.color = color
        
        super.init(overlay: polyline)
    }
    
    public init(polyline: MKPolyline, color: UIColor, showsBorder: Bool, borderColor: UIColor) {
        self.polyline = polyline
        self.color = color
        self.showsBorder = showsBorder
        self.borderColor = borderColor
        
        super.init(overlay: polyline)
    }
    
    public override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let baseWidth: CGFloat = lineWidth / zoomScale
        
        if showsBorder {
            context.setLineWidth(baseWidth * 2)
            context.setLineJoin(CGLineJoin.round)
            context.setLineCap(CGLineCap.round)
            context.addPath(path)
            context.setStrokeColor(borderColor.cgColor)
            context.strokePath()
        }
        
        context.setLineWidth(baseWidth)
        context.addPath(path)
        context.setStrokeColor(color.cgColor)
        context.strokePath()
        
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
    
    public override func createPath() {
        let path: CGMutablePath  = CGMutablePath()
        var pathIsEmpty: Bool = true
        
        for i in 0...self.polyline.pointCount - 1 {
            let point: CGPoint = self.point(for: self.polyline.points()[i])
            if pathIsEmpty {
                path.move(to: point)
                pathIsEmpty = false
            } else {
                path.addLine(to: point)
            }
        }
        self.path = path
    }
}
