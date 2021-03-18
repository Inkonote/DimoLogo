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

private let baseReference: CGFloat = 60.0
private let arcRadiusRatio: CGFloat = 1.0 / 12.0
private let controlPointOffsetYRatio: CGFloat = 1.0 / 15.0
private let stretchLengthRatio: CGFloat = 1.0 / 15.0
private let waterDropElemMaxIntervalRatio: CGFloat = 7.0 / 30.0
private let lineMarginHorizontalRatio: CGFloat = 1.0 / 12.0
private let lineWidthRatio: CGFloat = 1.0 / 20.0
private let bounceSizeRatio: CGFloat = 1.0 / 60.0
private let lineStretchLengthsRatio: [CGFloat] = [0.2, 2.0 / 15.0, 0.1]

public class DimoLogoView: UIView {

    private var displayLink: DisplayLinkWrapper?

    private var waterDrop: WaterDrop = WaterDrop()
    private var line: Line = Line()

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
        reference = max(reference, baseReference)

        waterDrop.arcRadius = reference * arcRadiusRatio
        waterDrop.stretchLength = reference * stretchLengthRatio
        waterDrop.controlPointOffsetY = reference * controlPointOffsetYRatio
        waterDrop.bounceSize = reference * bounceSizeRatio
        waterDrop.elemMaxInterval = reference * waterDropElemMaxIntervalRatio

        line.marginHorizontal = reference * lineMarginHorizontalRatio

        line.width = reference * lineWidthRatio

        line.stretchLengths = lineStretchLengthsRatio.map { $0 * reference }

        setNeedsDisplay()
    }

    private func updateTimes() {
        waterDrop.animationTimeRange.setPop(startExpand: 0,
                                            startShrink: (animationDuration * 0.125),
                                            endShrink: (animationDuration * 0.15))

        waterDrop.animationTimeRange.setMove(startStand: 0,
                                             startMove: waterDrop.animationTimeRange.shrink.upperBound,
                                             endMove: (animationDuration * 0.85))

        waterDrop.animationTimeRange.setDeform(start: 0,
                                               startStretch: animationDuration * 0.5,
                                               endStretch: animationDuration * 0.875)

        waterDrop.animationTimeRange.fadeIn = (animationDuration * 0.8)...(animationDuration * 1)

        let lineStretchTimes = [animationDuration * 0.5,
                                animationDuration * 0.8,
                                animationDuration * 0.9,
                                animationDuration * 1]
        
        line.stretchTimeRanges = [lineStretchTimes[0]...lineStretchTimes[1],
                                  lineStretchTimes[1]...lineStretchTimes[2],
                                  lineStretchTimes[2]...lineStretchTimes[3]]
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        foregroundColor.setFill()
        foregroundColor.setStroke()
        waterDrop.draw(bounds: bounds, lineWidth: line.width, time: time, context: context)
        line.draw(bounds: bounds, time: time)
    }

    @objc private func fire() {
        time += 0.05
        setNeedsDisplay()
    }

}
