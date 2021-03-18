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
    
    struct AnimationTimeRange {
        var fadeIn: ClosedRange<CGFloat> = 0...0

        var expand: ClosedRange<CGFloat> = 0...0
        var shrink: ClosedRange<CGFloat> = 0...0

        var standing: ClosedRange<CGFloat> = 0...0
        var move: ClosedRange<CGFloat> = 0...0

        var round: ClosedRange<CGFloat> = 0...0
        var stretch: ClosedRange<CGFloat> = 0...0
    }

    var bounceSize: CGFloat = 1
    var animationTimeRange: AnimationTimeRange = AnimationTimeRange()

    var elemMaxInterval: CGFloat = 14.0
    var arcRadius: CGFloat = 5.0
    var stretchLength: CGFloat = 4.0
    var controlPointOffsetY: CGFloat = 4.0

    func draw(bounds: CGRect, lineWidth: CGFloat, time: CGFloat, context: CGContext) {
        var arcCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 - elemMaxInterval - (arcRadius + lineWidth) / 2.0)
        var alpha: CGFloat = 1

        // move
        if !animationTimeRange.standing.contains(time) {
            let elapsed = time - animationTimeRange.move.lowerBound
            let distance: CGFloat = 2 * (bounds.height / 2.0 - arcCenter.y)
            arcCenter.y += distance * min(1, elapsed / animationTimeRange.move.length)
        }

        var radius = arcRadius

        if animationTimeRange.expand.contains(time) {
            let elapsed = time - animationTimeRange.expand.lowerBound
            radius = (arcRadius + bounceSize) * elapsed / animationTimeRange.expand.length
        } else if animationTimeRange.shrink.contains(time) {
            let elapsed = time - animationTimeRange.shrink.lowerBound
            radius = arcRadius + bounceSize * (1 - elapsed / animationTimeRange.shrink.length)
        }

        if animationTimeRange.round.contains(time) {
            context.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .fill)
        } else {

            if time >= animationTimeRange.fadeIn.lowerBound {
                let elapsed = time - animationTimeRange.fadeIn.lowerBound
                alpha = 1 - elapsed / animationTimeRange.fadeIn.length
                //                print("time: \(time) elapsed: \(elapsed) alpha: \(alpha)")
            }

            let elapsed = time - animationTimeRange.stretch.lowerBound
            path(progress: min(1, elapsed / animationTimeRange.stretch.length), arcCenter: arcCenter).fill(with: .normal, alpha: alpha)
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

struct Line {
    var marginHorizontal: CGFloat = 5.0
    var width: CGFloat = 3.0
    var stretchLengths: [CGFloat] = [12, -8, 6]
    var stretchTimeRanges: [ClosedRange<CGFloat>] = []
    
    func draw(bounds: CGRect, time: CGFloat) {
        let centerPoint = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        let lineLength = bounds.width - 2 * marginHorizontal
        var midLineCenterPoint = centerPoint
        let maxOffsets: [CGFloat] = stretchLengths
        
        if let index = stretchTimeRanges.firstIndex(where: { $0.contains(time) }) {
            let range = stretchTimeRanges[index]
            let maxOffset = maxOffsets[index]
            let elapsed = time - range.lowerBound
            var progress = elapsed / range.length
            if progress > 0.5 {
                progress = abs(1 - progress)
            }
            midLineCenterPoint.y += maxOffset * progress
        }

        let midLinePoints = LinePoints(left: CGPoint(x: centerPoint.x - lineLength / 2.0, y: centerPoint.y), center: midLineCenterPoint, right: CGPoint(x: centerPoint.x + lineLength / 2.0, y: centerPoint.y))

        let topLinePoints: LinePoints = midLinePoints.offsetting(y: -width / 2.0)
        let bottomLinePoints: LinePoints = midLinePoints.offsetting(y: width / 2.0)
        draw(topLinePoints: topLinePoints, bottomLinePoints: bottomLinePoints)
    }
    
    private func draw(topLinePoints: LinePoints, bottomLinePoints: LinePoints) {
        let linePath = UIBezierPath()
        linePath.lineJoinStyle = .miter

        linePath.move(to: topLinePoints.left)
        linePath.addQuadCurve(to: topLinePoints.center, controlPoint: topLinePoints.left.offset(offsetX: 16))
        linePath.addQuadCurve(to: topLinePoints.right, controlPoint: topLinePoints.right.offset(offsetX: -16))
        linePath.addLine(to: bottomLinePoints.right)
        linePath.addQuadCurve(to: bottomLinePoints.center, controlPoint: bottomLinePoints.right.offset(offsetX: -16))
        linePath.addQuadCurve(to: bottomLinePoints.left, controlPoint: bottomLinePoints.left.offset(offsetX: 16))
        linePath.addLine(to: topLinePoints.left)

        linePath.fill()
    }
}
