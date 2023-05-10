//
//  TopRoundedCornersShape.swift
//  FindWay
//
//  Created by Oleksandr Haidaiev on 02.04.2023.
//

import SwiftUI

struct TopRoundedCorners: Shape {
    var topLeftRadius: CGFloat
    var topRightRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeftArcCenter = CGPoint(x: rect.minX + topLeftRadius, y: rect.minY + topLeftRadius)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
        path.addArc(center: topLeftArcCenter,
                    radius: topLeftRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        
        let topRightArcCenter = CGPoint(x: rect.maxX - topRightRadius, y: rect.minY + topRightRadius)
        path.addArc(center: topRightArcCenter,
                    radius: topRightRadius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}
