//
//  MagicianNode.swift
//  BookCore
//
//  Created by apple on 2021/2/23.
//

import UIKit


enum ArrowDirection: Int {
    case right = 0   //指向右边, 即在圆角矩形的右边
    case bottom = 1  //指向下边
    case left = 2   //指向左边
    case top = 3   //指向上边
}

class BubbleLayer: NSObject {
   
    // 矩形的圆角的半径
    var cornerRadius: CGFloat = 8
    // 箭头位置的圆角半径
    var arrowRadius: CGFloat = 3
    // 箭头的高度
    var arrowHeight: CGFloat = 12
    // 箭头的宽度
    var arrowWidth: CGFloat = 30
    // 箭头方向
    var arrowDirection: Int = 1
    // 箭头的相对位置
    var arrowPosition: CGFloat = 0.5
    // 这里的size是需要mask成气泡形状的view的size
    var size: CGSize = CGSize.zero
    
    
    init(originalSize: CGSize) {
        size = originalSize
    }
    
    //最终拿这个layer去设置mask
    func layer() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = self.bubblePath()
        return layer
    }
    
    
    // 绘制气泡形状,获取path
    func bubblePath() -> CGPath? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        
        // 获取绘图所需要的关键点
        let points = self.keyPoints()
        
        // 第一步是要画箭头的“第一个支点”所在的那个角，所以要把“笔”放在这个支点顺时针顺序的上一个点
        // 所以把“笔”放在最后才画的矩形框的角的位置, 准备开始画箭头
        let currentPoint = points[6]
        ctx?.move(to: currentPoint)
        
        // 用于 CGContextAddArcToPoint函数的变量
        var pointA = CGPoint.zero
        var pointB = CGPoint.zero
        var radius: CGFloat = 0
        var count: Int = 0
        
        while count < 7 {
            radius = count < 3 ? arrowRadius : cornerRadius
            
            pointA = points[count]
            pointB = points[(count + 1) % 7]
            
            ctx?.addArc(tangent1End: pointA, tangent2End: pointB, radius: radius)
            
            count = count + 1
            
        }
        
        ctx?.closePath()
        UIGraphicsEndImageContext()
        
        return ctx?.path?.copy()
    }
    
    
    // 关键点: 绘制气泡形状前，需要计算箭头的三个点和矩形的四个角的点的坐标
    func keyPoints() -> Array<CGPoint> {
        
        // 先确定箭头的三个点
        var beginPoint = CGPoint.zero // 按顺时针画箭头时的第一个支点，例如箭头向上时的左边的支点
        var topPoint = CGPoint.zero // 顶点
        var endPoint = CGPoint.zero // 另外一个支点
        
        // 箭头顶点topPoint的X坐标(或Y坐标)的范围（用来计算arrowPosition）
        let tpXRange = size.width - 2 * cornerRadius - arrowWidth
        let tpYRange = size.height - 2 * cornerRadius - arrowWidth
        
        // 用于表示矩形框的位置和大小
        var rX: CGFloat = 0
        var rY: CGFloat = 0
        var rWidth = size.width
        var rHeight = size.height
        
        // 计算箭头的位置，以及调整矩形框的位置和大小
        switch arrowDirection {
            
        case 0: //箭头在右时
            topPoint = CGPoint(x: size.width, y: size.height / 2 + tpYRange * (arrowPosition - 0.5))
            beginPoint = CGPoint(x: topPoint.x - arrowHeight, y:topPoint.y - arrowWidth / 2 )
            endPoint = CGPoint(x: beginPoint.x, y: beginPoint.y + arrowWidth)
            
            rWidth = rWidth - arrowHeight //矩形框右边的位置“腾出”给箭头
            
        case 1: //箭头在下时
            topPoint = CGPoint(x: size.width / 2 + tpXRange * (arrowPosition - 0.5), y: size.height)
            beginPoint = CGPoint(x: topPoint.x + arrowWidth / 2, y:topPoint.y - arrowHeight )
            endPoint = CGPoint(x: beginPoint.x - arrowWidth, y: beginPoint.y)
            
            rHeight = rHeight - arrowHeight
            
        case 2: //箭头在左时
            topPoint = CGPoint(x: 0, y: size.height / 2 + tpYRange * (arrowPosition - 0.5))
            beginPoint = CGPoint(x: topPoint.x + arrowHeight, y: topPoint.y + arrowWidth / 2)
            endPoint = CGPoint(x: beginPoint.x, y: beginPoint.y - arrowWidth)
            
            rX = arrowHeight
            rWidth = rWidth - arrowHeight
            
        case 3: //箭头在上时
            topPoint = CGPoint(x: size.width / 2 + tpXRange * (arrowPosition - 0.5), y: 0)
            beginPoint = CGPoint(x: topPoint.x - arrowWidth / 2, y: topPoint.y + arrowHeight)
            endPoint = CGPoint(x: beginPoint.x + arrowWidth, y: beginPoint.y)
            
            rY = arrowHeight
            rHeight = rHeight - arrowHeight
            
        default:
            ()
        }

        // 先把箭头的三个点放进关键点数组中
        var points = [beginPoint, topPoint, endPoint]
        
        //确定圆角矩形的四个点
        let bottomRight = CGPoint(x: rX + rWidth, y: rY + rHeight); //右下角的点
        let bottomLeft = CGPoint(x: rX, y: rY + rHeight);
        let topLeft = CGPoint(x: rX, y: rY);
        let topRight = CGPoint(x: rX + rWidth, y: rY);
        
        //先放在一个临时数组, 放置顺序跟下面紧接着的操作有关
        let rectPoints = [bottomRight, bottomLeft, topLeft, topRight]
        
        // 绘制气泡形状的时候，从箭头开始,顺时针地进行
        // 箭头向右时，画完箭头之后会先画到矩形框的右下角
        // 所以此时先把矩形框右下角的点放进关键点数组,其他三个点按顺时针方向添加
        // 箭头在其他方向时，以此类推
        
        var rectPointIndex: Int = arrowDirection
        for _ in 0...3 {
            points.append(rectPoints[rectPointIndex])
            rectPointIndex = (rectPointIndex + 1) % 4
        }
        
        return points
    }
    

}
