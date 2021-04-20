//
//  SKBloodNode.swift
//  BookCore
//
//  Created by apple on 2021/3/12.
//


import SpriteKit

public class SKBloodNode: SKSpriteNode {
    
    private var canMove: Bool!
    private var globalSclae: CGFloat { GameCenter.shared.globalSclae }
    private lazy var bloodSize = CGSize(width: 50*globalSclae, height: 50*globalSclae)
    private var labelNode = SKLabelNode()
    private var magicianP: CGPoint { GameCenter.shared.magicianPoint }
    private var textureNode: SKSpriteNode!
    private var dismissTimer: Timer? // 计时器。每0.5秒检测是否出界
    private var gameLabel: String! {
        didSet{
            self.labelNode.attributedText = generateAttributed()
        }
    }
    // 爱心被识别，增加血量
    private var shouldDismiss = false {
        didSet{
            dismissAction()
        }
    }
    private var guidTimer: Timer?
    
    convenience init(move: Bool) {
        self.init(color: .clear, size: CGSize.zero)
        if !move {
            self.bloodSize = CGSize(width: 100*globalSclae, height: 100*globalSclae)
        }
        self.canMove = move
        setUpBlood()
        setUpGameLabel()
        setUpNotifications()
        runMoveAction()
    }
    
    deinit {
        self.dismissTimer?.invalidate()
        self.guidTimer?.invalidate()
    }
    
    func guidGusture() {
        NotificationCenter.default.post(Notification(name: Notification.Name("stop_GuidGesture")))
        self.guidTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            let t = ResultType.circle
            NotificationCenter.default.post(name: Notification.Name("add_GuidGesture"), object: nil, userInfo: ["symbolType" : t])
        })
    }
}

extension SKBloodNode {
    
    //加载png资源
    private func loadPng() -> SKTexture? {
        let name = "heart_1"
        guard let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "png"),
              let image = UIImage(contentsOfFile: path) else { return nil }
        return SKTexture(image: image)
    }
    
    // 设置符号Label
    private func setUpGameLabel() {
        self.gameLabel = ResultType.circle.stringValue
        self.addChild(labelNode)
        labelNode.position = CGPoint(x: 0, y: self.bloodSize.height/2+15)
        labelNode.zPosition = 1
    }
    
    // 将箭头符号变成富文本
    private func generateAttributed() -> NSAttributedString? {
        guard gameLabel != "" else { return nil }
        let circleColor = ResultType.circle.color
        let attribute: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .heavy),
            NSAttributedString.Key.foregroundColor: circleColor
        ]
        let attrStr = NSAttributedString(string: gameLabel, attributes: attribute)
        return attrStr
    }
    
    private func setUpNotifications() {
        //接收检测手势
        NotificationCenter.default.addObserver(self, selector: #selector(beAttacked(noti:)), name: NSNotification.Name("gestureSign"), object: nil)
        dismissTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(outSideDetect), userInfo: nil, repeats: true)
        dismissTimer?.fire()
    }
    
    // 自动移动
    private func runMoveAction() {
        guard self.canMove else { return }
        let height = Int(UIScreen.main.bounds.height)
        let width = Int(UIScreen.main.bounds.width)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -50, y: Int.random(from: height/3, to: 2*height/3)))
        path.addCurve(to: CGPoint(x: width+100, y: height/2), controlPoint1: CGPoint(x: 200, y: 600), controlPoint2: CGPoint(x: 600, y: 20))
        
        let action = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: 40)
        self.run(action, withKey: "autoMove")
    }
    
    // 手势识别后更新病毒剩余的virus箭头符号
    @objc private func beAttacked(noti: Notification) {
        guard self.shouldDismiss == false,
            let sign = noti.userInfo?["sign"] as? String else { return }
        
        let firstSign = String(self.gameLabel.prefix(1))
        if firstSign == sign {
            self.gameLabel = String(self.gameLabel.dropFirst())
            if self.gameLabel == "" {
                self.guidTimer?.invalidate()
                NotificationCenter.default.post(Notification(name: Notification.Name("stop_GuidGesture")))
                self.shouldDismiss = true
            }
        }
    }
    
    private func setUpBlood() {
        textureNode = SKSpriteNode()
        textureNode.size = self.bloodSize
        // 静态图片初始化
        textureNode.texture = loadPng()
        let scaleAct = SKAction.sequence([SKAction.scale(to: 1.3, duration: 2),SKAction.scale(to: 1, duration: 2)])
        let fadeAct = SKAction.sequence([SKAction.fadeAlpha(to: 1, duration: 2),SKAction.fadeAlpha(to: 0.8, duration: 2)])
        let act = SKAction.group([scaleAct, fadeAct])
        
        self.textureNode.run(SKAction.repeatForever(act), withKey: "PngAction")
        self.addChild(textureNode)
    }
    
    private func dismissAction() {
        if shouldDismiss {
            let dismissAct = SKAction.fadeAlpha(to: 0, duration: 1.2)
            dismissAct.timingMode = .easeIn
            self.physicsBody = nil
            self.textureNode.removeAction(forKey: "pngAction")
            if !self.canMove {
                self.run(dismissAct) {
                    self.removeFromParent()
                    self.dismissTimer?.invalidate()
                    NotificationCenter.default.post(Notification(name: Notification.Name("blood_get")))
                }
                return
            }
            //先移动到人物旁边，再慢慢消失。
            self.removeAction(forKey: "autoMove")
            let v = self.magicianP - self.position
            let moveAction = SKAction.move(by: CGVector(dx: v.x, dy: v.y), duration: 1.2)
            moveAction.timingMode = .easeIn
            self.labelNode.run(dismissAct)
            self.textureNode.run(moveAction) {
                GameCenter.shared.addBlood()
                self.run(dismissAct) {
                    self.removeFromParent()
                    self.dismissTimer?.invalidate()
                }
            }
        }
    }
    
    //出界检测，如果出界自动消失
    @objc private func outSideDetect() {
        guard !UIScreen.main.bounds.insetBy(dx: -100, dy: -100).contains(self.position) else { return }
        self.removeFromParent()
        dismissTimer?.invalidate()
    }
    
    //判断blood是否被识别
    func IsIdentified() -> Bool {
        return self.shouldDismiss
    }
}
