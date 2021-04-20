//
//  GameScene.swift
//  BookCore
//
//  Created by apple on 2021/3/9.
//

import UIKit
import SpriteKit

public class GameScene: SKScene {
    
    private var gameManager = GameManager()
    private var state: GameState { GameCenter.shared.gameState }
    private var backgroundImage: SKSpriteNode!
    private var bloodNum = 10
    private var bloodNodes: [SKSpriteNode] = []
    private var TimeLabel = SKShapeNode()
    private var leftTimeLabel = SKNode()
    private var middleTimeLabel = SKLabelNode()
    private var rightTimeLabel = SKNode()
    private let TimeLabelSize = CGSize(width: 200, height: 80)
    private var continueNode: SKSpriteNode?
    private var ScoreLable = SKNode()
    private let ScoreLabelSize = CGSize(width: 300, height: 80)
    private var gameTimer: Timer?
    private var gameTime = 0
    
    public override init(size: CGSize) {
        super.init(size: UIScreen.main.bounds.size)
        self.backgroundColor = UIColor.white
        
        setUpScene()
        setUpNotifications()
        gameManager.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - private初始化函数
    private func setUpScene() {
        //背景图片
        backgroundImage = SKSpriteNode()
        backgroundImage.texture = SKTexture(imageNamed: "png/background\(GameCenter.shared.rankNum).jpg")
        backgroundImage.size = self.size
        backgroundImage.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(backgroundImage)
        
        //顶部时间
        self.addChild(TimeLabel)
        TimeLabel.zPosition = 2
        TimeLabel.path = CGPath(roundedRect: CGRect(origin: CGPoint(x: -TimeLabelSize.width/2, y: -TimeLabelSize.height/2), size: TimeLabelSize), cornerWidth: 30, cornerHeight: 20, transform: nil)
        TimeLabel.position = CGPoint(x: self.size.width/2, y: self.size.height-TimeLabelSize.height/2-60)
        TimeLabel.fillColor = #colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1)
        
        middleTimeLabel.position = CGPoint.zero
        TimeLabel.addChild(middleTimeLabel)
        
        //分数板
        let starLabel = SKSpriteNode(imageNamed: "png/star")
        self.addChild(starLabel)
        starLabel.zPosition = 2
        starLabel.size = CGSize(width: ScoreLabelSize.height*0.7, height: ScoreLabelSize.height*0.7)
        starLabel.position = CGPoint(x: self.size.width-ScoreLabelSize.width/2-ScoreLabelSize.height-50, y: self.size.height-TimeLabelSize.height/2-100)
        
        self.addChild(ScoreLable)
        ScoreLable.zPosition = 2
        ScoreLable.position = CGPoint(x: self.size.width-ScoreLabelSize.width/2-20, y: self.size.height-TimeLabelSize.height/2-100)
        
        //血量
        for i in 0..<10 {
            let bloodNode = SKSpriteNode(texture: SKTexture(imageNamed: "png/heart_1.png"))
            bloodNode.color = UIColor.white
            bloodNode.size = CGSize(width: 60, height: 60)
            bloodNode.position = CGPoint(x: (i%5)*70+50, y: Int(UIScreen.main.bounds.height) - (i<5 ? 110:180))
            bloodNode.isHidden = true
            self.addChild(bloodNode)
            self.bloodNodes.append(bloodNode)
        }
    }
    
    func setUpNotifications() {
        //在scene上改变血量
        NotificationCenter.default.addObserver(self, selector: #selector(updateBlood), name: NSNotification.Name("Blood_Changed"), object: nil)
        //在scene上改变分数
        NotificationCenter.default.addObserver(self, selector: #selector(updateScore), name: NSNotification.Name("Score_Changed"), object: nil)
        //游戏状态改变，判断是否:失败\胜利
        NotificationCenter.default.addObserver(self, selector: #selector(gameStateChange), name: NSNotification.Name("GameState_Changed"), object: nil)
        //开始设计游戏时，删除所有node
        NotificationCenter.default.addObserver(self, selector: #selector(removeAllVirus), name: NSNotification.Name("Start_Design"), object: nil)
    }
    
    //MARK: - 刷新时间和血量
    @objc private func updateTime() {
        guard self.state == .running else { return }
        gameTime += 1
        
        TimeLabel.addNumToNode(num: gameTime, width: TimeLabelSize.width)
    }
    
    @objc private func updateBlood() {
        let blood = GameCenter.shared.getBlood()
        guard blood >= 0 , blood <= GameCenter.maxBlood else { return }
        if blood < bloodNum {
            for i in blood..<bloodNum {
                self.bloodNodes[i].run(SKAction.scale(to: 0.9, duration: 0.2)) {
                    self.bloodNodes[i].run(SKAction.scale(to: 1, duration: 0.1))
                    self.bloodNodes[i].texture = SKTexture(imageNamed: "png/heart_2.png")
                }
            }
        }else {
            for i in bloodNum..<blood {
                self.bloodNodes[i].run(SKAction.scale(to: 1.1, duration: 0.2)) {
                    self.bloodNodes[i].run(SKAction.scale(to: 1, duration: 0.1))
                    self.bloodNodes[i].texture = SKTexture(imageNamed: "png/heart_1.png")
                }
            }
        }
        bloodNum = blood
    }
    
    @objc func removeAllVirus() {
        //删除还未消失的virus,blood,blastNode
        for node in self.children {
            if node is SKBloodNode || node is SKVirusNode {
                node.removeFromParent()
            }
            
            if node.name == "blastNode" {
                node.removeFromParent()
            }
        }
    }
    
    
    //MARK: - 开始\暂停\继续
    func startGame() {
        backgroundImage.texture = SKTexture(imageNamed: "png/background\(GameCenter.shared.rankNum).jpg")
        GameCenter.shared.gameState = .start
        gameTime = 0
        //重制最大血量
        bloodNum = GameCenter.maxBlood
        for i in 0..<10 {
            self.bloodNodes[i].texture = SKTexture(imageNamed: "png/heart_1.png")
            self.bloodNodes[i].isHidden = (i >= bloodNum)
        }
        
        //删除还未消失的virus,blood,blastNode
        for node in self.children {
            if node is SKBloodNode || node is SKVirusNode {
                node.removeFromParent()
            }
            
            if node.name == "blastNode" {
                node.removeFromParent()
            }
        }
        
        
        
        TimeLabel.addNumToNode(num: gameTime, width: TimeLabelSize.width)
        gameManager.startGame()
        
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        continueGame()
    }
    
    func pauseGame() {
        GameAudio.share.backGroundAudio(audio: .none)
        for node in self.children {
            node.isPaused = true
        }
    }
    
    func continueGame() {
        guard self.state == .paused || self.state == .start else { return }
        GameAudio.share.backGroundAudio(audio: .begin)
        
        // 3,2,1,0倒数计时后继续游戏
        guard self.continueNode == nil else { return }
        var t = 3
        continueNode = SKSpriteNode(imageNamed: "number_1/\(t)")
        continueNode!.position = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        continueNode!.zPosition = 3
        let continueNodeSize = CGSize(width: 300, height: 300)
        continueNode!.size = continueNodeSize
        continueNode!.run(SKAction.scale(to: 0.7, duration: 0.8))
        self.addChild(continueNode!)
        
        let continueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            t -= 1
            if t>=0 {
                self.continueNode!.texture = SKTexture(imageNamed: "number_1/\(t)")
                self.continueNode!.scale(to: continueNodeSize)
                self.continueNode!.run(SKAction.scale(to: 0.7, duration: 0.8))
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            self.continueNode!.removeFromParent()
            self.continueNode = nil
            for node in self.children {
                node.isPaused = false
            }
            GameAudio.share.backGroundAudio(audio: .back)
            GameCenter.shared.gameState = .running
            continueTimer.invalidate()
        }
    }
    
    //MARK: - 游戏状态改变，判断
    @objc private func gameStateChange() {
        switch self.state {
        case .lost: gameLost()
        case .win: gameWin()
        case .end: gameOver()
        default: break
        }
    }
    
    //MARK: - 游戏失败动画
    private func gameLost() {
        guard self.state == .lost else { return }
        GameAudio.share.backGroundAudio(audio: .none)
        for node in self.children {
            if let Mnode = node as? MagicianNode {
                Mnode.dieLost()
            }
            
            if let Vnode = node as? SKVirusNode {
                Vnode.dieLost()
            }
            
            if node is SKBloodNode {
                node.removeFromParent()
            }
            
            if node.name == "blastNode" {
                node.removeFromParent()
            }
        }
    }
    
    //MARK: - 游戏胜利动画
    @objc private func gameWin() {
        guard self.state == .win else { return }
        GameAudio.share.backGroundAudio(audio: .win)
        for node in self.children {
            if node is SKBloodNode {
                node.removeFromParent()
            }
            
            if node.name == "blastNode" {
                node.removeFromParent()
            }
        }
        
        let LeftStarsNode = SKEmitterNode()
        LeftStarsNode.zPosition = 3
        LeftStarsNode.particleTexture = SKTexture(imageNamed: "png/star")
        LeftStarsNode.particleBirthRate = 60
        LeftStarsNode.particlePosition = CGPoint.zero
        LeftStarsNode.particlePositionRange = CGVector(dx: 300, dy: 300)
        LeftStarsNode.particleSize = CGSize(width: 50, height: 50)
        LeftStarsNode.particleSpeed = 500
        LeftStarsNode.particleSpeedRange = 80
        LeftStarsNode.particleLifetime = 2
        LeftStarsNode.particleLifetimeRange = 1
        LeftStarsNode.emissionAngle = CGFloat.pi/6
        LeftStarsNode.emissionAngleRange = CGFloat.pi/8
        LeftStarsNode.yAcceleration = -30
        LeftStarsNode.xAcceleration = -15
        LeftStarsNode.particleRotation = 0
        LeftStarsNode.particleRotationRange = CGFloat.pi/2
        LeftStarsNode.particleRotationSpeed = -CGFloat.pi/18
        LeftStarsNode.particleColorAlphaSpeed = 0.15
        self.addChild(LeftStarsNode)
        
        let RightStarsNode = SKEmitterNode()
        RightStarsNode.zPosition = 3
        RightStarsNode.particleTexture = SKTexture(imageNamed: "png/star")
        RightStarsNode.particleBirthRate = 60
        RightStarsNode.particlePosition = CGPoint(x: UIScreen.main.bounds.width, y: 0)
        RightStarsNode.particlePositionRange = CGVector(dx: 300, dy: 300)
        RightStarsNode.particleSize = CGSize(width: 50, height: 50)
        RightStarsNode.particleSpeed = 500
        RightStarsNode.particleSpeedRange = 80
        RightStarsNode.particleLifetime = 2
        RightStarsNode.particleLifetimeRange = 1
        RightStarsNode.emissionAngle = 5*CGFloat.pi/6
        RightStarsNode.emissionAngleRange = CGFloat.pi/8
        RightStarsNode.yAcceleration = -30
        RightStarsNode.xAcceleration = -15
        RightStarsNode.particleRotation = 0
        RightStarsNode.particleRotationRange = CGFloat.pi/2
        RightStarsNode.particleRotationSpeed = CGFloat.pi/18
        RightStarsNode.particleColorAlphaSpeed = 0.15
        self.addChild(RightStarsNode)
        
        
        LeftStarsNode.run(.sequence([.wait(forDuration: 5),
                                     .fadeAlpha(to: 0, duration: 1.5),
                                     .removeFromParent()]))
        RightStarsNode.run(.sequence([.wait(forDuration: 5),
                                      .fadeAlpha(to: 0, duration: 1.5),
                                      .removeFromParent(),
                                      .run({GameCenter.shared.gameState = .end})]))
    }
    
    //MARK: - 游戏完全结束，暂停
    private func gameOver() {
        guard self.state == .end else { return }
        GameAudio.share.backGroundAudio(audio: .none)
        pauseGame()
    }
}


//MARK: - Manager调用scene的协议
extension GameScene: GameManagerDelegate {
    
    func addToView(node: SKNode) {
        self.addChild(node)
    }
    
    @objc func updateScore() {
        let score = GameCenter.shared.getScore()
        ScoreLable.addNumToNode(num: score, width: self.ScoreLabelSize.width, numSet: 1)
        ScoreLable.removeAction(forKey: "scaleScore")
        ScoreLable.run(SKAction.scale(to: 1.4, duration: 0.1), withKey: "scaleScore")
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
            self.ScoreLable.run(SKAction.scale(to: 1, duration: 0.2), withKey: "scaleScore")
        }
    }
    
    func allVirusDied() -> Bool {
        let virusNum = self.children.filter { node -> Bool in
            if node is SKVirusNode {
                if UIScreen.main.bounds.insetBy(dx: -200, dy: -200).contains(node.position){
                    return true
                } else {
                    node.removeFromParent()
                    return false
                }
            }
            if let blood = node as? SKBloodNode,
               blood.IsIdentified() { return true }
            return false
        }.count
        return virusNum == 0
    }
}

//MARK: - SKNode用图片显示数字
extension SKNode {
    func addNumToNode(num: Int, width: CGFloat, numSet: Int=0) {
        var setNum = numSet
        if setNum<0 || setNum>1 {
            setNum=0
        }
        
        var numCopy = num
        var arr: [Int] = []
        
        if numCopy == 0 {
            arr.append(0)
        } else {
            while numCopy != 0 {
                arr.append(numCopy % 10)
                numCopy /= 10
            }
        }
        
        
        var cnt = 0
        let total = arr.count
        
        let preSize = CGSize(width: width/CGFloat(total+3), height: width/CGFloat(total+3))
        
        self.removeAllChildren()
        while arr.count != 0 {
            cnt += 1
            let last = arr.popLast()!
            let node = SKSpriteNode(imageNamed: "number_\(setNum)/\(last)")
            node.size = preSize
            node.position = CGPoint(x: CGFloat(cnt+1)/CGFloat(total+1+2) * width - width/2, y: 0)
            self.addChild(node)
        }
    }
}
