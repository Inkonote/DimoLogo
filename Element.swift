//
//  Element.swift
//  DimoLogo
//
//  Created by ty0x2333 on 2021/3/19.
//

import Foundation

struct LinePoints {
    let left: CGPoint
    let center: CGPoint
    let right: CGPoint

    func offsetting(y: CGFloat) -> LinePoints {
        return LinePoints(left: left.offset(offsetY: y), center: center.offset(offsetY: y), right: right.offset(offsetY: y))
    }
}

struct WaterDrop {

    var bounceSize: CGFloat = 1

    var fadeInTimeRange: ClosedRange<CGFloat> = 0...0

    var expandTimeRange: ClosedRange<CGFloat> = 0...0
    var shrinkTimeRange: ClosedRange<CGFloat> = 0...0

    var standingTimeRange: ClosedRange<CGFloat> = 0...0
    var moveTimeRange: ClosedRange<CGFloat> = 0...0

    var roundTimeRange: ClosedRange<CGFloat> = 0...0
    var stretchTimeRange: ClosedRange<CGFloat> = 0...0

    var elemMaxInterval: CGFloat = 14.0
    var arcRadius: CGFloat = 5.0
    var stretchLength: CGFloat = 4.0
    var controlPointOffsetY: CGFloat = 4.0

    func draw(bounds: CGRect, lineWidth: CGFloat, time: CGFloat, context: CGContext) {
        var arcCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 - elemMaxInterval - (arcRadius + lineWidth) / 2.0)
        var alpha: CGFloat = 1

        // move
        if !standingTimeRange.contains(time) {
            let elapsed = time - moveTimeRange.lowerBound
            let distance: CGFloat = 2 * (bounds.height / 2.0 - arcCenter.y)
            arcCenter.y += distance * min(1, elapsed / moveTimeRange.length)
        }

        var radius = arcRadius

        if expandTimeRange.contains(time) {
            let elapsed = time - expandTimeRange.lowerBound
            radius = (arcRadius + bounceSize) * elapsed / expandTimeRange.length
        } else if shrinkTimeRange.contains(time) {
            let elapsed = time - shrinkTimeRange.lowerBound
            radius = arcRadius + bounceSize * (1 - elapsed / shrinkTimeRange.length)
        }

        if roundTimeRange.contains(time) {
            context.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .fill)
        } else {

            if time >= fadeInTimeRange.lowerBound {
                let elapsed = time - fadeInTimeRange.lowerBound
                alpha = 1 - elapsed / fadeInTimeRange.length
                //                print("time: \(time) elapsed: \(elapsed) alpha: \(alpha)")
            }

            let elapsed = time - stretchTimeRange.lowerBound
            path(progress: min(1, elapsed / stretchTimeRange.length), arcCenter: arcCenter).fill(with: .normal, alpha: alpha)
        }
    }

    /// Get water drop 💧 UIBezierPath
    /// - Parameters:
    ///   - process: water drop animation progress
    ///   - arcCenter: water drop center
    /// - Returns: water drop  bezier path
    private func path(progress: CGFloat, arcCenter: CGPoint) -> UIBezierPath {
        let waterDropTop = arcCenter.offset(offsetY: -arcRadius - stretchLength * progress)

        let waterDrop = UIBezierPath()
        waterDrop.move(to: waterDropTop)
        waterDrop.addQuadCurve(to: arcCenter.offset(offsetX: arcRadius), controlPoint: arcCenter.offset(offsetX: arcRadius, offsetY: -controlPointOffsetY))
        waterDrop.addArc(withCenter: arcCenter, radius: arcRadius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
        waterDrop.move(to: waterDropTop)
        waterDrop.addQuadCurve(to: arcCenter.offset(offsetX: -arcRadius), controlPoint: arcCenter.offset(offsetX: -arcRadius, offsetY: -controlPointOffsetY))

        return waterDrop
    }
}
