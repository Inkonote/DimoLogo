//
//  DimoLogoView.swift
//  DimoLogo
//
//  Created by ty0x2333 on 2018/10/5.
//

import UIKit

extension ClosedRange {
    var length: CGFloat {
        if let lowerBound = self.lowerBound as? CGFloat,
            let upperBound = self.upperBound as? CGFloat {
            return lowerBound.distance(to: upperBound)
        }
        return 0
    }
}

extension CGPoint {
    func offset(offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + offsetX, y: y + offsetY)
    }
}

struct LinePoints {
    let left: CGPoint
    let center: CGPoint
    let right: CGPoint
    
    func offsetting(y: CGFloat) -> LinePoints {
        return LinePoints(left: left.offset(offsetY: y), center: center.offset(offsetY: y), right: right.offset(offsetY: y))
    }
}

struct WaterDrop {
    
    var popTimeRange: ClosedRange<CGFloat> = 0...0
    var repopTimeRange: ClosedRange<CGFloat> = 0...0
    
    var standingTimeRange: ClosedRange<CGFloat> = 0...0
    var moveTimeRange: ClosedRange<CGFloat> = 0...0
    
    var roundTimeRange: ClosedRange<CGFloat> = 0...0
    var stretchTimeRange: ClosedRange<CGFloat> = 0...0
    
    var arcRadius: CGFloat = 5.0
    var stretchLength: CGFloat = 4.0
    var controlPointOffsetY: CGFloat = 4.0
    
    /// Get water drop 💧 UIBezierPath
    /// - Parameters:
    ///   - process: water drop animation progress
    ///   - arcCenter: water drop center
    /// - Returns: water drop  bezier path
    func path(progress: CGFloat, arcCenter: CGPoint) -> UIBezierPath {
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

public class DimoLogoView: UIView {
    private static let BaseReference: CGFloat = 60.0
    private static let arcRadiusRatio: CGFloat = 1.0 / 12.0
    private static let controlPointOffsetYRatio: CGFloat = 1.0 / 15.0
    private static let stretchLengthRatio: CGFloat = 1.0 / 15.0
    private static let WaterDropElemMaxIntervalRatio: CGFloat = 7.0 / 30.0
    private static let LineMarginHorizontalRatio: CGFloat = 1.0 / 12.0
    private static let LineWidthRatio: CGFloat = 1.0 / 20.0
    private static let BounceSizeRatio: CGFloat = 1.0 / 60.0
    private static let LineStretchLengthsRatio: [CGFloat] = [0.2, 2.0 / 15.0, 0.1]
    
    private var waterDropElemMaxInterval: CGFloat = 14.0
    private var lineMarginHorizontal: CGFloat = 5.0
    private var lineWidth: CGFloat = 3.0
    private var bounceSize: CGFloat = 1
    private var lineStretchLengths: [CGFloat] = [12, -8, 6]
    
    private var displayLink: DisplayLinkWrapper?
    
    private var fadeInTimeRange: ClosedRange<CGFloat> = 0...0
    
    private var lineStretchTimes: [CGFloat] = [0, 0, 0, 0]
    private var waterDrop: WaterDrop = WaterDrop()
    
    private class DisplayLinkWrapper {
        private weak var target: AnyObject?
        private var selector: Selector
        private var displayLink: CADisplayLink?
        
        init(target: AnyObject, selector: Selector) {
            self.target = target
            self.selector = selector
            displayLink = CADisplayLink(target: self, selector: #selector(fire))
            displayLink?.preferredFramesPerSecond = 20
            displayLink?.add(to: .main, forMode: .common)
        }
        
        @objc private func fire() {
            _ = target?.perform(selector)
        }
        
        func invalidate() {
            displayLink?.invalidate()
        }
    }
    
    var animationDuration: CGFloat = 1.2 {
        didSet {
            updateTimes()
        }
    }
    
    public var progress: CGFloat {
        set {
            stop()
            let progress: CGFloat = max(0, min(newValue, 1.0))
            time = animationDuration * progress
            setNeedsDisplay()
        }
        get {
            guard animationDuration > 0 else {
                return 0.0
            }
            let timeProgress = time / animationDuration
            return max(0, min(timeProgress, 1.0))
        }
    }
    
    private var time: CGFloat = 0 {
        didSet {
            if time > animationDuration + animationInterval {
                time = 0
            }
        }
    }
    
    public var foregroundColor: UIColor = UIColor.white {
        didSet {
            if displayLink == nil {
                setNeedsDisplay()
            }
        }
    }
    var animationInterval: CGFloat = 0.15
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        updateTimes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stop()
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    public func play() {
        guard displayLink == nil else {
            return
        }
        displayLink = DisplayLinkWrapper(target: self, selector: #selector(fire))
    }
    
    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        var reference: CGFloat = min(bounds.width, bounds.height)
        reference = max(reference, Self.BaseReference)
        
        waterDrop.arcRadius = reference * Self.arcRadiusRatio
        waterDrop.stretchLength = reference * Self.stretchLengthRatio
        waterDrop.controlPointOffsetY = reference * Self.controlPointOffsetYRatio
        
        lineMarginHorizontal = reference * Self.LineMarginHorizontalRatio
        
        lineWidth = reference * Self.LineWidthRatio
        
        bounceSize = reference * Self.BounceSizeRatio
        
        lineStretchLengths = Self.LineStretchLengthsRatio.map { $0 * reference }
        
        waterDropElemMaxInterval = reference * Self.WaterDropElemMaxIntervalRatio
        
        setNeedsDisplay()
    }
    
    private func updateTimes() {
        waterDrop.popTimeRange = 0.0...(animationDuration * 0.125)
        waterDrop.repopTimeRange = waterDrop.popTimeRange.upperBound...(animationDuration * 0.15)
        
        waterDrop.standingTimeRange = 0...waterDrop.repopTimeRange.upperBound
        waterDrop.moveTimeRange = waterDrop.repopTimeRange.upperBound...(animationDuration * 0.85)
        
        waterDrop.roundTimeRange = 0...(animationDuration * 0.5)
        waterDrop.stretchTimeRange = waterDrop.roundTimeRange.upperBound...(animationDuration * 0.875)
        fadeInTimeRange = (animationDuration * 0.8)...(animationDuration * 1)
        
        lineStretchTimes = [animationDuration * 0.5, animationDuration * 0.8, animationDuration * 0.9, animationDuration * 1]
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        foregroundColor.setFill()
        foregroundColor.setStroke()
        drawWaterDrop(time: time, context: context)
        drawLine(time: time)
    }
    
    private func drawWaterDrop(time: CGFloat, context: CGContext) {
        var arcCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 - waterDropElemMaxInterval - (waterDrop.arcRadius + lineWidth) / 2.0)
        var alpha: CGFloat = 1
        
        // move
        if !waterDrop.standingTimeRange.contains(time) {
            let elapsed = time - waterDrop.moveTimeRange.lowerBound
            let distance: CGFloat = 2 * (bounds.height / 2.0 - arcCenter.y)
            arcCenter.y += distance * min(1, elapsed / waterDrop.moveTimeRange.length)
        }
        
        var radius = waterDrop.arcRadius
        
        if waterDrop.popTimeRange.contains(time) {
            let elapsed = time - waterDrop.popTimeRange.lowerBound
            radius = (waterDrop.arcRadius + bounceSize) * elapsed / waterDrop.popTimeRange.length
        } else if waterDrop.repopTimeRange.contains(time) {
            let elapsed = time - waterDrop.repopTimeRange.lowerBound
            radius = waterDrop.arcRadius + bounceSize * (1 - elapsed / waterDrop.repopTimeRange.length)
        }
        
        if waterDrop.roundTimeRange.contains(time) {
            context.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .fill)
        } else {
            
            if time >= fadeInTimeRange.lowerBound {
                let elapsed = time - fadeInTimeRange.lowerBound
                alpha = 1 - elapsed / fadeInTimeRange.length
                //                print("time: \(time) elapsed: \(elapsed) alpha: \(alpha)")
            }
            
            let elapsed = time - waterDrop.stretchTimeRange.lowerBound
            waterDrop.path(progress: min(1, elapsed / waterDrop.stretchTimeRange.length), arcCenter: arcCenter).fill(with: .normal, alpha: alpha)
        }
    }
    
    private func drawLine(time: CGFloat) {
        let centerPoint = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        let lineLength = bounds.width - 2 * lineMarginHorizontal
        var midLineCenterPoint = centerPoint
        let maxOffsets: [CGFloat] = lineStretchLengths
        
        let stretchRanges: [ClosedRange<CGFloat>] = [lineStretchTimes[0]...lineStretchTimes[1],
                                                     lineStretchTimes[1]...lineStretchTimes[2],
                                                     lineStretchTimes[2]...lineStretchTimes[3]]
        
        for (index, range) in stretchRanges.enumerated() where range.contains(time) {
            let maxOffset = maxOffsets[index]
            let elapsed = time - range.lowerBound
            var progress = elapsed / range.length
            if progress > 0.5 {
                progress = abs(1 - progress)
            }
            midLineCenterPoint.y += maxOffset * progress
            break
        }
        
        let midLinePoints = LinePoints(left: CGPoint(x: centerPoint.x - lineLength / 2.0, y: centerPoint.y), center: midLineCenterPoint, right: CGPoint(x: centerPoint.x + lineLength / 2.0, y: centerPoint.y))
        
        let topLinePoints: LinePoints = midLinePoints.offsetting(y: -lineWidth / 2.0)
        let bottomLinePoints: LinePoints = midLinePoints.offsetting(y: lineWidth / 2.0)
        drawLine(topLinePoints: topLinePoints, bottomLinePoints: bottomLinePoints)
    }
    
    private func drawLine(topLinePoints: LinePoints, bottomLinePoints: LinePoints) {
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
    
    @objc private func fire() {
        time += 0.05
        setNeedsDisplay()
    }
    
}
