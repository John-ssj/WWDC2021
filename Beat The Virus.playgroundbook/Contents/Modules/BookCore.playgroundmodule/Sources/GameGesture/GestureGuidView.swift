//
//  GestureGuidView.swift
//  BookCore
//
//  Created by apple on 2021/4/16.
//

import UIKit
import PlaygroundSupport

public class GestureGuidView: UIView {
    
    let duration: CFTimeInterval = 1.5
    var pointView: UIImageView!
    var pathLayer: CAShapeLayer?
    var path: CGPath?
    var type: ResultType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        pointView = UIImageView(frame:CGRect(x: 0, y: 0, width: 120, height: 120))
        pointView.image = UIImage(named: "png/point")
        pointView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/6)
        pointView.backgroundColor = UIColor.clear
        pointView.isHidden = true
        pointView.layer.anchorPoint = CGPoint(x: 0.4, y: 0.15)
        self.addSubview(pointView)
    }
    
    public func setPathAndDraw(type: ResultType) {
        guard type != .unkonw else { return }
        self.type = type
        
        let centerX = self.bounds.size.width/2
        let centerY = self.bounds.size.height/2
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        switch type {
        case .left: getLeftPath()
        case .right: getRightPath()
        case .up: getUpPath()
        case .down: getDownPath()
        case .v: getVPath(transform)
        case .n: getNPath(transform)
        case .circle: getCirclePath()
        case .unkonw: break
        }
        
        drawPath()
    }
    
    public func stopDrawPath() {
        self.type = nil
        self.path = nil
        self.pointView.isHidden = true
        self.pointView.layer.removeAllAnimations()
        self.pathLayer?.removeAllAnimations()
        self.pathLayer?.removeFromSuperlayer()
        self.pathLayer = nil
    }
    
    private func getLeftPath() {
        let centerX = self.bounds.size.width/2
        let centerY = self.bounds.size.height*3/5
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        let p = CGMutablePath()
        p.move(to: CGPoint(x: self.bounds.size.width/4 ,y:0), transform: transform)
        p.addLine(to: CGPoint(x: -self.bounds.size.width/4 ,y:0), transform: transform)
        self.path = p
    }
    
    private func getRightPath() {
        let centerX = self.bounds.size.width/2
        let centerY = self.bounds.size.height*3/5
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        let p = CGMutablePath()
        p.move(to: CGPoint(x: -self.bounds.size.width/4 ,y:0), transform: transform)
        p.addLine(to: CGPoint(x: self.bounds.size.width/4 ,y:0), transform: transform)
        self.path = p
    }
    
    private func getUpPath() {
        let centerX = self.bounds.size.width/4
        let centerY = self.bounds.size.height*1/3
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        let p = CGMutablePath()
        p.move(to: CGPoint(x: 0, y: self.bounds.size.height/4), transform: transform)
        p.addLine(to: CGPoint(x: 0, y: -self.bounds.size.height/4), transform: transform)
        self.path = p
    }
    
    private func getDownPath() {
        let centerX = self.bounds.size.width/4
        let centerY = self.bounds.size.height*1/3
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        let p = CGMutablePath()
        p.move(to: CGPoint(x: 0, y: -self.bounds.size.height/4), transform: transform)
        p.addLine(to: CGPoint(x: 0, y: self.bounds.size.height/4), transform: transform)
        self.path = p
    }
    
    private func getVPath(_ transform: CGAffineTransform) {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: -self.bounds.size.width/6, y: -self.bounds.size.height/8), transform: transform)
        p.addLine(to: CGPoint(x: 0, y: self.bounds.size.height/8), transform: transform)
        p.addLine(to: CGPoint(x: self.bounds.size.width/6, y: -self.bounds.size.height/8), transform: transform)
        self.path = p
    }
    
    private func getNPath(_ transform: CGAffineTransform) {
        let p = CGMutablePath()
        p.move(to: CGPoint(x: -self.bounds.size.width/6, y: self.bounds.size.height/8), transform: transform)
        p.addLine(to: CGPoint(x: 0, y: -self.bounds.size.height/8), transform: transform)
        p.addLine(to: CGPoint(x: self.bounds.size.width/6, y: self.bounds.size.height/8), transform: transform)
        self.path = p
    }
    
    private func getCirclePath() {
        let centerX = self.bounds.size.width/2
        let centerY = self.bounds.size.height*3/5
        //创建用于转移坐标的Transform，这样我们不用按照实际显示做坐标计算
        let transform = CGAffineTransform(translationX: centerX, y: centerY)
        
        let p = CGMutablePath()
        p.addEllipse(in: CGRect(x: -self.bounds.size.width/6, y: -self.bounds.size.width/6, width: self.bounds.size.width/3, height: self.bounds.size.width/3), transform: transform)
        self.path = p
    }
    
    private func drawPath() {
        
        //给handView添加移动动画
        pointView.layer.removeAnimation(forKey: "Move")
        let orbit = CAKeyframeAnimation(keyPath:"position")
        orbit.duration = duration
        orbit.path = path
        orbit.calculationMode = .paced
        orbit.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        orbit.isRemovedOnCompletion = false
        orbit.fillMode = .forwards
        let orbit_Wait_Animation = CAAnimationGroup()
        orbit_Wait_Animation.animations = [orbit]
        orbit_Wait_Animation.duration = duration+1
        orbit_Wait_Animation.repeatCount = .greatestFiniteMagnitude
        pointView.layer.add(orbit_Wait_Animation,forKey:"Move")
        pointView.isHidden = false
        
        //绘制运动轨迹
        pathLayer = CAShapeLayer()
        pathLayer!.frame = self.bounds
        //pathLayer.isGeometryFlipped = true
        pathLayer!.path = path
        pathLayer!.fillColor = nil
        pathLayer!.lineWidth = 8
        pathLayer!.lineCap = .round
        pathLayer!.lineJoin = .round
        pathLayer!.strokeColor = self.type?.color.cgColor
        
        //给运动轨迹添加动画
        let pathAnimation = CABasicAnimation.init(keyPath: "strokeEnd")
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathAnimation.duration = duration
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        let path_Wait_Animation = CAAnimationGroup()
        path_Wait_Animation.animations = [pathAnimation]
        path_Wait_Animation.duration = duration+1
        path_Wait_Animation.repeatCount = .greatestFiniteMagnitude
        pathLayer!.add(path_Wait_Animation , forKey: "strokeEnd")
        
        //将轨道添加到视图层中
        self.layer.addSublayer(pathLayer!)
    }
}
