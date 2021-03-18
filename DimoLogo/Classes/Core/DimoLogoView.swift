//
//  DimoLogoView.swift
//  DimoLogo
//
//  Created by luckytianyiyan on 2018/10/5.
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

public class DimoLogoView: UIView {
    private static let BaseReference: CGFloat = 60.0
    private static let WaterDropArcRadiusRatio: CGFloat = 1.0 / 12.0
    private static let WaterDropControlPointOffsetYRatio: CGFloat = 1.0 / 15.0
    private static let WaterDroStretchLengthRatio: CGFloat = 1.0 / 15.0
    private static let WaterDropElemMaxIntervalRatio: CGFloat = 7.0 / 30.0
    private static let LineMarginHorizontalRatio: CGFloat = 1.0 / 12.0
    private static let LineWidthRatio: CGFloat = 1.0 / 20.0
    private static let BounceSizeRatio: CGFloat = 1.0 / 60.0
    private static let LineStretchLengthsRatio: [CGFloat] = [0.2, 2.0 / 15.0, 0.1]
    
    private var waterDropArcRadius: CGFloat = 5.0
    private var waterDropControlPointOffsetY: CGFloat = 4.0
    private var waterDroStretchLength: CGFloat = 4.0
    private var waterDropElemMaxInterval: CGFloat = 14.0
    private var lineMarginHorizontal: CGFloat = 5.0
    private var lineWidth: CGFloat = 3.0
    private var bounceSize: CGFloat = 1
    private var lineStretchLengths: [CGFloat] = [12, -8, 6]
    
    private var displayLink: DisplayLinkWrapper?
    
    private var popAnimationFinishedTime: CGFloat = 0
    private var repopAnimationFinishedTime: CGFloat = 0
    private var moveAnimationFinishedTime: CGFloat = 0
    private var waterDropStretchBeginTime: CGFloat = 0
    private var waterDropStretchFinishedTime: CGFloat = 0
    private var fadeInBeginTime: CGFloat = 0
    private var fadeInFinishedTime: CGFloat = 0
    
    private var lineStretchBeginTime: CGFloat = 0
    private var lineStretchFinishedTime: CGFloat = 0
    private var lineStretch2FinishedTime: CGFloat = 0
    private var lineStretch3FinishedTime: CGFloat = 0
    
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
        reference = max(reference, DimoLogoView.BaseReference)
        
        waterDropArcRadius = reference * DimoLogoView.WaterDropArcRadiusRatio
        
        waterDroStretchLength = reference * DimoLogoView.WaterDroStretchLengthRatio
        
        lineMarginHorizontal = reference * DimoLogoView.LineMarginHorizontalRatio
        
        lineWidth = reference * DimoLogoView.LineWidthRatio
        
        bounceSize = reference * DimoLogoView.BounceSizeRatio
        
        lineStretchLengths = DimoLogoView.LineStretchLengthsRatio.map { $0 * reference }
        
        waterDropControlPointOffsetY = reference * DimoLogoView.WaterDropControlPointOffsetYRatio
        
        waterDropElemMaxInterval = reference * DimoLogoView.WaterDropElemMaxIntervalRatio
        
        setNeedsDisplay()
    }
    
    private func updateTimes() {
        popAnimationFinishedTime = animationDuration * 0.125
        repopAnimationFinishedTime = animationDuration * 0.15
        moveAnimationFinishedTime = animationDuration * 0.85
        waterDropStretchBeginTime = animationDuration * 0.5
        waterDropStretchFinishedTime = animationDuration * 0.875
        fadeInBeginTime = animationDuration * 0.8
        fadeInFinishedTime = animationDuration * 1
        
        lineStretchBeginTime = animationDuration * 0.5
        lineStretchFinishedTime = animationDuration * 0.8
        lineStretch2FinishedTime = animationDuration * 0.9
        lineStretch3FinishedTime = animationDuration * 1
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
        var arcCenter = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0 - waterDropElemMaxInterval - (waterDropArcRadius + lineWidth) / 2.0)
        let popRange = 0.0...popAnimationFinishedTime
        let repopRange = popAnimationFinishedTime...repopAnimationFinishedTime
        let noMoveRange = 0.0...repopAnimationFinishedTime
        let moveRange = repopAnimationFinishedTime...moveAnimationFinishedTime
        let noStretchRange = 0.0...waterDropStretchBeginTime
        let stretchRange = waterDropStretchBeginTime...waterDropStretchFinishedTime
        let alphaRange = fadeInBeginTime...fadeInFinishedTime
        var alpha: CGFloat = 1
        
        // move
        if !noMoveRange.contains(time) {
            let elapsed = time - moveRange.lowerBound
            let distance: CGFloat = 2 * (bounds.height / 2.0 - arcCenter.y)
            arcCenter.y += distance * min(1, elapsed / moveRange.length)
        }
        
        var radius = waterDropArcRadius
        
        if popRange.contains(time) {
            let elapsed = time - popRange.lowerBound
            radius = (waterDropArcRadius + bounceSize) * elapsed / popRange.length
        } else if repopRange.contains(time) {
            let elapsed = time - repopRange.lowerBound
            radius = waterDropArcRadius + bounceSize * (1 - elapsed / repopRange.length)
        }
        
        if noStretchRange.contains(time) {
            context.addArc(center: arcCenter, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
            context.drawPath(using: .fill)
        } else {
            
            if time >= alphaRange.lowerBound {
                let elapsed = time - alphaRange.lowerBound
                alpha = 1 - elapsed / alphaRange.length
                //                print("time: \(time) elapsed: \(elapsed) alpha: \(alpha)")
            }
            
            let elapsed = time - stretchRange.lowerBound
            waterDrop(process: min(1, elapsed / stretchRange.length), arcCenter: arcCenter).fill(with: .normal, alpha: alpha)
        }
    }
    
    private func drawLine(time: CGFloat) {
        let boundsWidth = bounds.width
        let centerX = boundsWidth / 2.0
        let centerY = bounds.height / 2.0
        let lineLength = boundsWidth - 2 * lineMarginHorizontal
        let startPoint = CGPoint(x: centerX - lineLength / 2.0, y: centerY)
        let endPoint = CGPoint(x: centerX + lineLength / 2.0, y: centerY)
        let maxOffsets: [CGFloat] = lineStretchLengths
        var centerPoint = CGPoint(x: centerX, y: centerY)
        
        let stretchRanges: [ClosedRange<CGFloat>] = [lineStretchBeginTime...lineStretchFinishedTime,
                                                     lineStretchFinishedTime...lineStretch2FinishedTime,
                                                     lineStretch2FinishedTime...lineStretch3FinishedTime]
        
        for i in 0..<3 {
            let range = stretchRanges[i]
            let maxOffset = maxOffsets[i]
            if range.contains(time) {
                let elapsed = time - range.lowerBound
                var process = elapsed / range.length
                if process > 0.5 {
                    process = abs(1 - process)
                }
                centerPoint.y += maxOffset * process
                break
            }
        }
        
        let linePath = UIBezierPath()
        linePath.lineJoinStyle = .miter
        let lineWith2 = lineWidth / 2.0
        
        let leftTop = startPoint.offset(offsetY: -lineWith2)
        let centerTop = centerPoint.offset(offsetY: -lineWith2)
        let rightTop = endPoint.offset(offsetY: -lineWith2)
        
        let leftBottom = startPoint.offset(offsetY: lineWith2)
        let centerBottom = centerPoint.offset(offsetY: lineWith2)
        let rightBottom = endPoint.offset(offsetY: lineWith2)
        
        linePath.move(to: leftTop)
        linePath.addQuadCurve(to: centerTop, controlPoint: leftTop.offset(offsetX: 16))
        linePath.addQuadCurve(to: rightTop, controlPoint: rightTop.offset(offsetX: -16))
        linePath.addLine(to: rightBottom)
        linePath.addQuadCurve(to: centerBottom, controlPoint: rightBottom.offset(offsetX: -16))
        linePath.addQuadCurve(to: leftBottom, controlPoint: leftBottom.offset(offsetX: 16))
        linePath.addLine(to: leftTop)
        
        linePath.fill()
    }
    
    private func waterDrop(process: CGFloat, arcCenter: CGPoint) -> UIBezierPath {
        let waterDropTop = arcCenter.offset(offsetY: -waterDropArcRadius - waterDroStretchLength * process)
        
        let waterDrop = UIBezierPath()
        waterDrop.move(to: waterDropTop)
        waterDrop.addQuadCurve(to: arcCenter.offset(offsetX: waterDropArcRadius), controlPoint: arcCenter.offset(offsetX: waterDropArcRadius, offsetY: -waterDropControlPointOffsetY))
        waterDrop.addArc(withCenter: arcCenter, radius: waterDropArcRadius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
        waterDrop.move(to: waterDropTop)
        waterDrop.addQuadCurve(to: arcCenter.offset(offsetX: -waterDropArcRadius), controlPoint: arcCenter.offset(offsetX: -waterDropArcRadius, offsetY: -waterDropControlPointOffsetY))
        
        return waterDrop
    }
    
    @objc private func fire() {
        time += 0.05
        setNeedsDisplay()
    }
    
}
