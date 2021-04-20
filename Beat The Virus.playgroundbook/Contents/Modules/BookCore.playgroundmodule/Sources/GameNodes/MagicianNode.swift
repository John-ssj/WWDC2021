//
//  MagicianNode.swift
//  BookCore
//
//  Created by apple on 2021/2/23.
//

import SpriteKit

public class MagicianNode: SKSpriteNode {
    
    private var globalScale: CGFloat { GameCenter.shared.globalSclae }
    private var mainTexture: SKTexture?
    private lazy var magicianSize = CGSize(width: 140*1.1*globalScale, height: 170*1.1*globalScale)
    private var soldierNormalAction: SKAction?
    private var soldierAttackAction: SKAction?
    private var soldierAttackendAction: SKAction?
    private var soldierWoundsAction: SKAction?
    private var symbolNode: SKLabelNode!
    private var effectNode: SKEmitterNode!
    
    private var showSymbolTimer: Timer?
    
    convenience init() {
        self.init(color: .clear, size: CGSize.zero)
        setUpActions()
        setUpNodes()
        NotificationCenter.default.addObserver(self, selector: #selector(soldierAttackStart), name: NSNotification.Name(rawValue: "gestureStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showSymbolNode), name: NSNotification.Name(rawValue: "gestureSign"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(beAttacked(noti:)), name: NSNotification.Name(rawValue: "Blood_Changed"), object: nil)
    }
    
    private func setUpActions() {
        let resourceName = ["soldierNormal", "soldierAttack", "soldierWounds"]
        let actionTime: [CGFloat] = [1, 0.3, 0.6]
        for t in 0..<3 {
            guard let path = Bundle.main.path(forResource: resourceName[t], ofType: "gif", inDirectory: "gif") else {
                print("could not load Magic Wand in this path")
                return
            }
            let url = URL(fileURLWithPath: path)
            guard let gifData = try? Data(contentsOf: url),
                let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return }
            var images = [UIImage]()
            let imageCount = CGImageSourceGetCount(source)
            for i in 0 ..< imageCount {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: image))
                }
            }
            let frameTime = TimeInterval(actionTime[t] / CGFloat(imageCount))
            let action = SKAction.animate(with: images.map {SKTexture(image: $0)}, timePerFrame: frameTime)
            if t == 0 { self.soldierNormalAction = action; self.mainTexture = SKTexture(image: images.first!) }
            if t == 1 { self.soldierAttackAction = action }
            if t == 2 { self.soldierWoundsAction = action }
            images.removeAll()
            if t == 1 {
                for i in (0 ..< imageCount).reversed() {
                    if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                        images.append(UIImage(cgImage: image))
                    }
                }
                let T = TimeInterval(0.2 / CGFloat(imageCount))
                let act = SKAction.animate(with: images.map {SKTexture(image: $0)}, timePerFrame: T)
                self.soldierAttackendAction = act
            }
        }
    }
    
    private func setUpNodes() {
        self.size = magicianSize
        self.texture = mainTexture
        
        self.symbolNode = SKLabelNode()
        self.symbolNode.position = CGPoint(x: 0, y: 170*1.1*globalScale/2)
        self.symbolNode.zPosition = 5
        self.symbolNode.alpha = 0
        self.addChild(symbolNode)
        
        effectNode = SKEmitterNode(fileNamed: "SparkAnimation.sks")
        effectNode.position = CGPoint(x: 0, y: 160*1.1*globalScale/2)
        effectNode.alpha = 0
        self.addChild(effectNode)
        
        soldierNormolState()
    }
    
    private func soldierNormolState() {
        self.showSymbolTimer?.invalidate()
        self.effectNode.removeAllActions()
        self.removeAllActions()
        self.effectNode.alpha = 0
        if self.soldierNormalAction != nil {
            self.run(.repeatForever(self.soldierNormalAction!), withKey: "soldierAction")
        }
    }
    
    @objc private func soldierAttackStart() {
        self.showSymbolTimer?.invalidate()
        self.effectNode.removeAllActions()
        self.removeAllActions()
        self.effectNode.alpha = 0
        self.symbolNode.alpha = 0
        if self.soldierAttackAction != nil {
            let act = SKAction.group([
                self.soldierAttackAction!,
                .sequence([.wait(forDuration: 0.2),
                           .run {
                            self.effectNode.run(.fadeAlpha(to: 1, duration: 0.1))
                           }])
            ])
            self.run(act, withKey: "soldierAction")
        }
    }
    
    @objc private func showSymbolNode(noti: Notification) {
        guard let s = noti.userInfo?["sign"] as? String,
              let symbol = ResultType(stringValue: s) else {
            soldierNormolState()
            return
        }
        // 改变并显示symbolNode
        self.symbolNode.alpha = 0
        self.symbolNode.attributedText = NSAttributedString(string: s, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 200, weight: .heavy),
            NSAttributedString.Key.foregroundColor: symbol.color
        ])
        self.symbolNode.alpha = 1
        self.effectNode.run(.fadeAlpha(to: 0, duration: 0.1))
        self.symbolNode.run(.sequence([.wait(forDuration: 0.4), .fadeAlpha(to: 0, duration: 0.1)]))
        showSymbolTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
            if self.soldierAttackendAction != nil {
                self.run(.sequence([self.soldierAttackendAction!,
                                    .run {
                                        self.soldierNormolState()
                                    }]))
            } else {
                self.soldierNormolState()
            }
        })
    }
    
    @objc private func beAttacked(noti: Notification) {
        guard let beAtt = noti.userInfo?["attack"] as? Bool, beAtt else { return }
        
        self.showSymbolTimer?.invalidate()
        self.effectNode.removeAllActions()
        self.removeAllActions()
        self.effectNode.alpha = 0
        GameAudio.share.playAudio(audio: .attack)
        if self.soldierNormalAction != nil {
            self.run(self.soldierWoundsAction!, withKey: "soldierAction")
            self.showSymbolTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false, block: { _ in
                self.soldierNormolState()
            })
        }
    }
    
    //游戏lost时,
    func dieLost() {
        self.showSymbolTimer?.invalidate()
        self.effectNode.removeAllActions()
        self.removeAllActions()
        self.effectNode.alpha = 0
        self.physicsBody = nil
        //先放大，再爆炸，慢慢缩小，最后消失。
        let dismissAction = SKAction.fadeAlpha(to: 0, duration: 0.8)
        dismissAction.timingMode = .easeIn
        let scaleBig = SKAction.scale(to: 1.3, duration: 0.4)
        scaleBig.timingMode = .easeIn
        self.run(scaleBig) {
            GameAudio.share.playAudio(audio: .attack)
            self.texture = SKTexture(imageNamed: "png/star")
            self.run(dismissAction) {
                self.removeFromParent()
            }
        }
    }
}
