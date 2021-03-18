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

public class DimoLogoView: UIView {
    private static let baseReference: CGFloat = 60.0
    private static let arcRadiusRatio: CGFloat = 1.0 / 12.0
    private static let controlPointOffsetYRatio: CGFloat = 1.0 / 15.0
    private static let stretchLengthRatio: CGFloat = 1.0 / 15.0
    private static let waterDropElemMaxIntervalRatio: CGFloat = 7.0 / 30.0
    private static let lineMarginHorizontalRatio: CGFloat = 1.0 / 12.0
    private static let lineWidthRatio: CGFloat = 1.0 / 20.0
    private static let bounceSizeRatio: CGFloat = 1.0 / 60.0
    private static let lineStretchLengthsRatio: [CGFloat] = [0.2, 2.0 / 15.0, 0.1]
    
    private var lineMarginHorizontal: CGFloat = 5.0
    private var lineWidth: CGFloat = 3.0
    private var lineStretchLengths: [CGFloat] = [12, -8, 6]
    
    private var displayLink: DisplayLinkWrapper?
    
    private var lineStretchTimes: [CGFloat] = [0, 0, 0, 0]
    private var waterDrop: WaterDrop = WaterDrop()
    
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
        reference = max(reference, Self.baseReference)
        
        waterDrop.arcRadius = reference * Self.arcRadiusRatio
        waterDrop.stretchLength = reference * Self.stretchLengthRatio
        waterDrop.controlPointOffsetY = reference * Self.controlPointOffsetYRatio
        waterDrop.bounceSize = reference * Self.bounceSizeRatio
        waterDrop.elemMaxInterval = reference * Self.waterDropElemMaxIntervalRatio
        
        lineMarginHorizontal = reference * Self.lineMarginHorizontalRatio
        
        lineWidth = reference * Self.lineWidthRatio
        
        lineStretchLengths = Self.lineStretchLengthsRatio.map { $0 * reference }
        
        setNeedsDisplay()
    }
    
    private func updateTimes() {
        waterDrop.expandTimeRange = 0.0...(animationDuration * 0.125)
        waterDrop.shrinkTimeRange = waterDrop.expandTimeRange.upperBound...(animationDuration * 0.15)
        
        waterDrop.standingTimeRange = 0...waterDrop.shrinkTimeRange.upperBound
        waterDrop.moveTimeRange = waterDrop.shrinkTimeRange.upperBound...(animationDuration * 0.85)
        
        waterDrop.roundTimeRange = 0...(animationDuration * 0.5)
        waterDrop.stretchTimeRange = waterDrop.roundTimeRange.upperBound...(animationDuration * 0.875)
        waterDrop.fadeInTimeRange = (animationDuration * 0.8)...(animationDuration * 1)
        
        lineStretchTimes = [animationDuration * 0.5, animationDuration * 0.8, animationDuration * 0.9, animationDuration * 1]
    }
    
    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        foregroundColor.setFill()
        foregroundColor.setStroke()
        waterDrop.draw(bounds: bounds, lineWidth: lineWidth, time: time, context: context)
        drawLine(time: time)
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
