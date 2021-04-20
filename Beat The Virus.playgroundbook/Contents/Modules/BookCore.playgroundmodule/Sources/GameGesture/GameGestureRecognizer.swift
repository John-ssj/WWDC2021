import UIKit
import PlaygroundSupport

public class GameGestureRecognizer: UIGestureRecognizer {
    
    private var touchedPoints: [CGPoint] = []
    var fitResult = CircleResult()
    var tolerance: CGFloat = 0.15
    var path = CGMutablePath()

    var result: ResultType = .unkonw
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1 else {
            state = .failed
            return
        }
        state = .began
        
        if let loc = touches.first?.location(in: view) {
            touchedPoints.append(loc)
            path.move(to: loc)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gestureStart"), object: self)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        if let loc = touches.first?.location(in: view) {
            touchedPoints.append(loc)
            path.addLine(to: loc)
        }
        
        matchResult()
        if self.result != .unkonw {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gestureSign"), object: self, userInfo: ["sign" : self.result.stringValue])
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gestureSign"), object: self)
        }
        state = .ended
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        // 1
        if state == .began {
            state = .changed
        } else if state == .failed{
            return
        }

        // 2
        if let loc = touches.first?.location(in: view) {
            touchedPoints.append(loc)
            path.addLine(to: loc)
        }
        
        matchResult()
    }
    
    public override func reset() {
        touchedPoints.removeAll(keepingCapacity: true)
        path = CGMutablePath()
        result = .unkonw
        super.reset()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        touchedPoints.removeAll(keepingCapacity: true)
        path = CGMutablePath()
        result = .unkonw
        state = .cancelled
    }
    
}


// MARK: - 识别圆形
extension GameGestureRecognizer {
    
    private func anyPointsInTheMiddle() -> Bool {
        // 1
        let fitInnerRadius = fitResult.radius / sqrt(2) * tolerance
        // 2
        let innerBox = CGRect(
            x: fitResult.center.x - fitInnerRadius,
            y: fitResult.center.y - fitInnerRadius,
            width: 2 * fitInnerRadius,
            height: 2 * fitInnerRadius)
        
        // 3
        var hasInside = false
        for point in touchedPoints {
            if innerBox.contains(point) {
                hasInside = true
                break
            }
        }
        
        return hasInside
    }
    
    private func calculateBoundingOverlap() -> CGFloat {
        // 1
        let fitBoundingBox = CGRect(
            x: fitResult.center.x - fitResult.radius,
            y: fitResult.center.y - fitResult.radius,
            width: 2 * fitResult.radius,
            height: 2 * fitResult.radius)
        let pathBoundingBox = path.boundingBox
        
        // 2
        let overlapRect = fitBoundingBox.intersection(pathBoundingBox)
        
        // 3
        let overlapRectArea = overlapRect.width * overlapRect.height
        let circleBoxArea = fitBoundingBox.height * fitBoundingBox.width
        
        let percentOverlap = overlapRectArea / circleBoxArea
        return percentOverlap
    }
    
    private func isCircle() -> Bool {
        fitResult = fitCircle(points: touchedPoints)
        
        // make sure there are no points in the middle of the circle
        let hasInside = anyPointsInTheMiddle()
        
        let percentOverlap = calculateBoundingOverlap()
        let isCircle = fitResult.error <= tolerance &&
            !hasInside && percentOverlap > (1-tolerance)
        return isCircle
    }
}


// MARK: - 识别上下左右
public extension GameGestureRecognizer {
    private enum CheckmarkPhases {
//        case notStarted
        case initialPoint
        case downStroke
        case upStroke
    }
    
    private func matchResult() {
        let n = self.result.rawValue
        
        if n<7, isCircle() {
            self.result = .circle
        } else if n<5 {
            if isV() {
                self.result = .v
            } else if isN() {
                self.result = .n
            } else if isUp() {
                self.result = .up
            } else if isDown() {
                self.result = .down
            } else if isLeft() {
                self.result = .left
            } else if isRight() {
                self.result = .right
            }
        }
    }

    private func isV() -> Bool {
        var prePoint : CGPoint? = nil
        var strokePhase: CheckmarkPhases!
        var minY: CGPoint?

        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                strokePhase = .initialPoint
                continue
            }
            if point.x + 5 < prePoint!.x { return false }
            if strokePhase == .initialPoint {
                // Make sure the initial movement is down and to the right.
                if point.y >= prePoint!.y {
                    strokePhase = .downStroke
                } else {
                    return false
                }
            } else if strokePhase == .downStroke {
                if point.y < prePoint!.y {
                    minY = prePoint
                    strokePhase = .upStroke
                }
            } else if strokePhase == .upStroke {
                if point.y > prePoint!.y {
                    return false
                }
            }
            prePoint = point
        }
        if strokePhase == .upStroke
            && minY!.y-25 > touchedPoints.first!.y
            && minY!.y-25 > touchedPoints.last!.y {
            return true
        } else {
            return false
        }
    }
    
    private func isN() -> Bool {
        var prePoint : CGPoint? = nil
        var strokePhase: CheckmarkPhases!
        var maxY: CGPoint?

        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                strokePhase = .initialPoint
                continue
            }
            if point.x + 5 < prePoint!.x { return false }
            if strokePhase == .initialPoint {
                // Make sure the initial movement is down and to the right.
                if point.y <= prePoint!.y {
                    strokePhase = .upStroke
                } else {
                    return false
                }
            } else if strokePhase == .upStroke {
                if point.y > prePoint!.y {
                    maxY = prePoint
                    strokePhase = .downStroke
                }
            } else if strokePhase == .downStroke {
                if point.y < prePoint!.y {
                    return false
                }
            }
            prePoint = point
        }
        if strokePhase == .downStroke
            && maxY!.y+25 < touchedPoints.first!.y
            && maxY!.y+25 < touchedPoints.last!.y {
            return true
        } else {
            return false
        }
    }
    
    private func isUp() -> Bool {
        var prePoint : CGPoint? = nil
        var errorNum = 0
        
        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                continue
            }
            if point.y > prePoint!.y { return false }
            if (abs(point.x - prePoint!.x) > abs(point.y - prePoint!.y)/2) { errorNum += 1 }
        }
        if errorNum <= touchedPoints.count / 5 { return true }
        return false
    }
    
    private func isDown() -> Bool {
        var prePoint : CGPoint? = nil
        var errorNum = 0

        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                continue
            }
            if point.y < prePoint!.y { return false }
            if (abs(point.x - prePoint!.x) > abs(point.y - prePoint!.y)/2) { errorNum += 1 }
        }
        if errorNum <= touchedPoints.count / 5 { return true }
        return false
    }
    
    private func isLeft() -> Bool {
        var prePoint : CGPoint? = nil
        var errorNum = 0

        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                continue
            }
            if point.x > prePoint!.x { return false }
            if (abs(point.x - prePoint!.x)/2 < abs(point.y - prePoint!.y)) { errorNum += 1 }
        }
        if errorNum <= touchedPoints.count / 5 { return true }
        return false
    }
    
    private func isRight() -> Bool {
        var prePoint : CGPoint? = nil
        var errorNum = 0

        for point in touchedPoints {
            if prePoint == nil {
                prePoint = point
                continue
            }
            if point.x < prePoint!.x { return false }
            if (abs(point.x - prePoint!.x)/2 < abs(point.y - prePoint!.y)) { errorNum += 1 }
        }
        if errorNum <= touchedPoints.count / 5 { return true }
        return false
    }
}
