//
//  GameManager.swift
//  BookCore
//
//  Created by apple on 2021/2/23.
//

import UIKit
import SpriteKit

public class GameManager: NSObject {
    // MARK: - 关键变量
    
    /**
     * 是否暂停
     * - 只有当状态是running的时候才不是暂停
     */
    var state: GameState { GameCenter.shared.gameState }
    /** 游戏进行时间 */
    private var time: Int = 0
    /** 游戏最后的virus出现的时间 */
//    private var endTime = TimeInterval.zero
    /** 游戏每秒刷新时钟 */
    private var gameTimer: Timer?
    /** 游戏关卡数据,从GameCenter中获得 */
    private var virusDic: [VirusRow] {
        GameCenter.shared.getVirusDic()
    }
    /** 当前virusDic的下一行是第几话 */
    private var rowNum: Int = 0 {
        didSet {
            if self.rowNum < self.virusDic.count {
                self.nextRow = VirusDic.getPresentRow(dic: self.virusDic, at: self.rowNum)
                return
            } else if GameCenter.shared.isEndLess {
                self.nextRow = VirusDic.getPresentRow(dic: self.virusDic, at: self.rowNum)
                return
            }
            self.nextRow =  nil
        }
    }
    /** 当前virusDic的下一行 */
    private var nextRow: VirusRow?
    /** 当下一行的mode是Time时，下一次生产virus的时间 */
    private var nextTime: Int = 1
    /** 魔术师位置 */
    private var magicianP: CGPoint { GameCenter.shared.magicianPoint }
    /** 魔术师node */
    private var magician: MagicianNode?
    /** 是否可以生产新的blood */
    private var newBlood = true
    /** 游戏是否结束,若结束,则timer不再刷新 */
    private var gameIsOver: Bool {
        GameCenter.shared.gameState == .win || GameCenter.shared.gameState == .lost
    }
    private var noVirus: Bool {
        self.delegate.allVirusDied()
    }
    /** 连接manager和Scene的代理 */
    var delegate: GameManagerDelegate!
    
    private var specialTimer: Timer?
    
    private var width: CGFloat {UIScreen.main.bounds.width}
    private var height: CGFloat {UIScreen.main.bounds.height}
    
    // MARK: - init
    override init() {
        super.init()
        
        setUpNotifications()
    }
    
    
    // MARK: - public函数
    func startGame() {
        guard GameCenter.shared.gameState == .start else { return }
        magician?.removeFromParent()
        magician = MagicianNode()
        if magician != nil {
            magician!.position = magicianP
            self.delegate.addToView(node: magician!)
        }
        
        // 重置游戏数据
        time = 0
        rowNum = 0
        nextTime = 1
        newBlood = true
        specialTimer?.invalidate()
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(upDataTime), userInfo: nil, repeats: true)
    }
    
    
    // MARK: - private函数
    private func setUpNotifications() {
        // 添加新病毒
        NotificationCenter.default.addObserver(self, selector: #selector(addVirus(noti:)), name: NSNotification.Name(rawValue: "add_Virus"), object: nil)
        // 添加爆炸病毒被消灭后留下阴影
        NotificationCenter.default.addObserver(self, selector: #selector(addBlast(noti:)), name: NSNotification.Name(rawValue: "add_blast"), object: nil)
        //暂停继续specialTimer
        NotificationCenter.default.addObserver(self, selector: #selector(changeSpecialTimer), name: NSNotification.Name("GameState_Changed"), object: nil)
    }
    
    @objc private func changeSpecialTimer() {
        if GameCenter.shared.gameState == .paused {
            self.specialTimer?.fireDate = .distantFuture
        } else if GameCenter.shared.gameState == .running {
            self.specialTimer?.fireDate = Date()
        }
    }
    
    //MARK: - 主刷新函数
    /** 每秒从dic中更新病毒,并检测是否需要生产blood,判断游戏是否结束 */
    @objc private func upDataTime() {
        //游戏状态为.lost时调用这部分代码
        if GameCenter.shared.gameState == .lost, self.noVirus {
            self.gameTimer?.invalidate()
            GameCenter.shared.gameState = .end
        }
        //游戏状态为.running时调用这部分代码
        guard self.state == .running, self.magician != nil else { return }
        
        self.time += 1
        if self.newBlood == true, GameCenter.shared.getBlood() < GameCenter.maxBlood {
            self.newBlood = false
            let bloodNode = SKBloodNode(move: true)
            bloodNode.position = CGPoint.zero
            bloodNode.zPosition = 0.8
            self.delegate.addToView(node: bloodNode)
            Timer.scheduledTimer(withTimeInterval: 25, repeats: false) { _ in
                self.newBlood = true
            }
        }
        if self.nextRow != nil {
            if (self.nextRow!.timeMode == .Time && self.time == self.nextTime) ||
                (self.nextRow!.timeMode == .Wait && self.noVirus) {
                
                if self.nextRow!.groupV { createGroupOfNormals() }
                if self.nextRow!.fastV { createFastAttack() }
                
                for _ in 0..<self.nextRow!.normolNum{
                    let virusNode = SKVirusNode(virusName: .normalVirus)
                    virusNode.position = getRandomVirusP()
                    self.delegate.addToView(node: virusNode)
                }
                
                if let dic = self.nextRow?.virus {
                    for v in dic {
                        let virusNode = SKVirusNode(virusName: v.name, symbol: v.symbol)
                        virusNode.position = getRandomVirusP(dir: v.dir, fromP: v.fromP, toP: v.toP)
                        self.delegate.addToView(node: virusNode)
                    }
                }
                
                self.rowNum += 1
                self.nextTime = self.time + (self.nextRow?.time ?? 0)
            }
            
        } else if GameCenter.shared.getBlood() > 0, self.noVirus {
            GameCenter.shared.gameState = .win
            self.gameTimer?.invalidate()
        }
    }
    
    // MARK: - 新游戏模式设计
    private func newVirus() {
        createGroupOfNormals()
        createFastAttack()
    }
    
    // 一大群YellowTails
    private func createGroupOfNormals() {
        let oringeP = CGPoint(x: self.width, y: self.height/2)
        for i in 0..<5 {
            let vNum = i<2 ? i : 2
            for j in -vNum...vNum {
                let virusNode = SKVirusNode(virusName: .normalVirus, dir: CGVector(dx: -1, dy: 0))
                virusNode.name = "groupNormals"
                virusNode.position = CGPoint(x: oringeP.x+virusNode.size.width*CGFloat(i-1),
                                             y: oringeP.y+virusNode.size.height*CGFloat(j))
                self.delegate.addToView(node: virusNode)
            }
        }
    }
    
    //快速攻击
    private func createFastAttack() {
        self.specialTimer?.invalidate()
        
        let t: CGFloat = 3
        var times = 4
        
        var points = [CGPoint(x: 0 ,y: 0),
                      CGPoint(x: 0 ,y: self.height),
                      CGPoint(x: self.width ,y: 0),
                      CGPoint(x: self.width ,y: self.height)]
        
        self.specialTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(t), repeats: true) { _ in
            guard self.state == .running else { return }
            times -= 1
            if times < 0 {
                self.specialTimer?.invalidate()
                return
            }
            let virusNode = SKVirusNode(virusName: .yellowTail, movetime: t-1, symbol: "H")
            virusNode.name = "fastAttack_Virus"
            virusNode.position = points.remove(at: Int.random(to: points.count-1))
            self.delegate.addToView(node: virusNode)
        }
        self.specialTimer?.fire()
    }
}


// MARK: - 添加viurs和爆炸烟雾
extension GameManager {
    
    @objc private func addVirus(noti: Notification) {
        guard self.state == .running || self.state == .paused else { return }
        guard let virusList = noti.userInfo?["virusInfo"] as? [VirusNames: Int],
              var point = noti.userInfo?["point"] as? CGPoint else { return }
        let parentHierarchy = (noti.userInfo?["hierarchy"] as? Int) ?? 0
        
        for virus in virusList {
            for _ in 0..<virus.value{
                let virusNode = SKVirusNode(virusName: virus.key)
                virusNode.virusHierarchy += parentHierarchy
                let dir = CGFloat(Int.random(to: 360)) / 360 * 2 * CGFloat.pi
                point.x += 20 * cos(dir)
                point.y += 20 * sin(dir)
                virusNode.position = point
                virusNode.alpha = 0.2
                virusNode.setScale(0.5)
                if self.state == .running {
                    GameAudio.share.playAudio(audio: .new)
                }
                self.delegate.addToView(node: virusNode)
                virusNode.run(SKAction.fadeAlpha(to: 1, duration: 0.6))
                virusNode.run(SKAction.scale(to: 1, duration: 2))
                if self.state != .running {
                    virusNode.isPaused = true
                }
            }
        }
    }
    
    @objc private func addBlast(noti: Notification) {
        guard let point = noti.userInfo?["point"] as? CGPoint else { return }
        
        let blastNode = SKSpriteNode()
        blastNode.texture = SKTexture(imageNamed: "png/blast")
        blastNode.size = CGSize(width: 150, height: 150)
        blastNode.name = "blastNode"
        blastNode.zPosition = 2
        blastNode.position = point
        blastNode.setScale(0.3)
        blastNode.alpha = 0.8
        self.delegate.addToView(node: blastNode)
        
        //先放大，保持5秒不变，然后变淡消失。
        let scaleAction = SKAction.scale(to: 3, duration: 0.1)
        scaleAction.timingMode = .easeIn
        let fadeAction = SKAction.fadeAlpha(to: 0, duration: 1)
        fadeAction.timingMode = .easeOut
        blastNode.run(.sequence([scaleAction,
                                 .wait(forDuration: 5),
                                 fadeAction,
                                 .removeFromParent()]))
    }
    
    // MARK: - new virus生成的位置
    enum Direction {
        case up
        case down
        case left
        case right
    }
    
    //获取随机病毒位置p
    private func getRandomVirusP(dir direction: [Direction]? = nil, fromP: CGFloat = 0.1, toP: CGFloat = 0.9) -> CGPoint {
        var dir: Direction?
        if direction == nil {
            // 有1/6的概率从上下出现，其他从左右出现。80%概率从远点那一边出现
            let upOrDown = Int.random(to: 6) == 1
            let normalDir = Int.random(to: 9) < 8
            if upOrDown {
                if self.magicianP.y > self.height/3 {
                    dir = normalDir ? .down : .up
                }else {
                    dir = normalDir ? .up : .down
                }
            }else {
                if self.magicianP.x > self.width/2 {
                    dir = normalDir ? .left : .right
                }else {
                    dir = normalDir ? .right : .left
                }
            }
        } else {
            dir = direction?.randomElement()
        }
        return getVirusP(dir: dir!, fromP: fromP, toP: toP)
    }
    
    private func getVirusP(dir: Direction, fromP: CGFloat, toP: CGFloat) -> CGPoint {
        var virusP = CGPoint.zero
        switch dir {
        case .down:
            virusP = CGPoint(x: Int.random(to: Int.random(from: Int(self.width*fromP), to: Int(self.width*toP))), y: -30)
        case .up:
            virusP = CGPoint(x: Int.random(to: Int.random(from: Int(self.width*fromP), to: Int(self.width*toP))), y: Int(self.height)+30)
        case .left:
            virusP = CGPoint(x: -30, y: Int.random(from: Int(self.height*fromP), to: Int(self.height*toP)))
        case .right:
            virusP = CGPoint(x: Int(self.width)+30, y: Int.random(from: Int(self.height*fromP), to: Int(self.height*toP)))
        }
        return virusP
    }
}


// MARK: - Manager的协议
protocol GameManagerDelegate {
    func addToView(node: SKNode)
    func allVirusDied() -> Bool
}

