//
//  SKVirusNode.swift
//  BookCore
//
//  Created by apple on 2021/2/22.
//

import SpriteKit

public class SKVirusNode: SKSpriteNode {
    
    //MARK: - 状态标记变量
    
    /** 第几代virus（部分virus需要）*/
    var virusHierarchy = 1
    /** 病毒信息 */
    private var virusInfo = VirusInfo()
    /** 计时器。每0.5秒进行一次碰撞检测 */
    private var atackTimer: Timer?
    /** 特殊病毒专用计时器 */
    private var specialTimer: Timer?
    /** 引导界面专用计时器 */
    private var guidTimer: Timer?
    /** 标记符号创建规则，根据规则可以创建symbols */
    private var symbolCreater: String!
    /** 标记符号 */
    private var symbols: String! { didSet{ updateAttributedLabel() } }
    /** 自动移动方式:向targetP移动，向某点移动，不移动 */
    var autoMove = MovingMode.noMove { didSet{ runMoveAction() } }
    /** 移动方向 */
    var movingDir: CGVector? = nil { didSet{ runMoveAction() } }
    /** 移动时间，设置后可用于快速移动到targetP */
    var movetime: CGFloat?
    /** 病毒放大系数 */
    var virusScale: CGFloat = 1
    /** 病毒被消灭，需要删除 */
    private var shouldDismiss = false { didSet{ dismissAction() } }
    /** gif/png资源在家成功，运行动画 */
    private var loadSuccess = false { didSet{ runMoveAction() } }
    var canMove: Bool! { didSet{ runMoveAction() } }
    /** 病毒名字，每次名字改变时都会重新加载gif资源 */
    var virusName: VirusNames! { didSet{ setUpVirus() } }
    
    /** target坐标 */
    var targetP: CGPoint { GameCenter.shared.magicianPoint }
    /** Node与target的距离 */
    var distance: CGFloat { hypot(self.targetP.x-self.position.x,
                                  self.targetP.y-self.position.y) }
    
    //MARK: - SubNodes
    /** 手势标记Node */
    private var labelNode: SKLabelNode!
    /** 图片展示Node */
    private var textureNode: SKSpriteNode!
    /** 朦层 */
    private var maskNode: SKShapeNode!
    
    
    //MARK: - 初始化
    convenience init(virusName: VirusNames, canMove: Bool = true, symbol: String? = nil) {
        self.init(color: .clear, size: CGSize.zero)
        self.virusName = virusName
        self.autoMove = .toPoint
        self.canMove = canMove
        
        setUpVirus(symbol)
        setUpNotifications()
    }
    
    convenience init(virusName: VirusNames, dir: CGVector, canMove: Bool = true, symbol: String? = nil) {
        self.init(color: .clear, size: CGSize.zero)
        self.virusName = virusName
        self.autoMove = .toDir
        self.movingDir = dir
        self.canMove = canMove
        
        setUpVirus(symbol)
        setUpNotifications()
    }
    
    convenience init(virusName: VirusNames, movetime: CGFloat? = nil, canMove: Bool = true, symbol: String? = nil) {
        self.init(color: .clear, size: CGSize.zero)
        self.virusName = virusName
        self.autoMove = .toPoint
        self.movetime = movetime
        self.canMove = canMove
        
        setUpVirus(symbol)
        setUpNotifications()
    }
    
    convenience init(virusName: VirusNames, moveMode: MovingMode = .noMove, scale: CGFloat = 1, canMove: Bool = true, symbol: String? = nil) {
        self.init(color: .clear, size: CGSize.zero)
        self.virusName = virusName
        self.autoMove = moveMode
        self.virusScale = scale
        self.canMove = canMove
        
        setUpVirus(symbol)
        setUpNotifications()
    }
    
    deinit {
        self.atackTimer?.invalidate()
        self.specialTimer?.invalidate()
        self.guidTimer?.invalidate()
    }
}



extension SKVirusNode {
    //MARK: - gif和png资源
    
    static let gifResource: [VirusNames: [SKTexture]] = {
        var dic = [VirusNames: [SKTexture]]()
        for virus in VirusNames.allCases {
            if virus == .normalVirus { continue }
            let resourceName = virus.rawValue
            guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif", inDirectory: "gif") else {
                print("Gif does not exist at that path")
                continue
            }
            let url = URL(fileURLWithPath: path)
            guard let gifData = try? Data(contentsOf: url),
                  let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { continue }
            var images = [UIImage]()
            let imageCount = CGImageSourceGetCount(source)
            for i in 0 ..< imageCount {
                if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images.append(UIImage(cgImage: image))
                }
            }
            let textures = images.map {SKTexture(image: $0)}
            dic[virus] = textures
        }
        print("load gif Success!")
        return dic
    }()
    
    static let pngResource: [SKTexture] = {
        var dic = [SKTexture]()
        for num in 1...8 {
            let name = "virus\(num)"
            guard let path = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "png"),
                  let image = UIImage(contentsOfFile: path) else { continue }
            dic.append(SKTexture(image: image))
        }
        print("load png Success!")
        return dic
    }()

    
    //MARK: - 内部方法
    // 加载gif资源
    private func setUpGif() {
        guard let textures = SKVirusNode.gifResource[self.virusName] else { return }
        let frameTime = self.virusInfo.duration / CGFloat(textures.count)

        self.textureNode.run(.setTexture(textures.first!))
        self.textureNode.run(SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: TimeInterval(frameTime))), withKey: "textureAction")
        self.loadSuccess = true
    }
    

    //加载png资源
    private func setUpPng() {
        self.textureNode?.texture = SKVirusNode.pngResource.randomElement()

        textureNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: 3, duration: TimeInterval(Int.random(from: 2, to: 5)))), withKey: "PngAction")
        self.loadSuccess = true
    }
    
    /** 定制符号字符串 */
    /// - parameter str: 输入字符串，
    /// "?"变成任意type，
    /// "V"变成'v'type，
    /// "N"变成'ʌ'type，
    /// "U"变成上type，
    /// "D"变成下type，
    /// "L"变成左type，
    /// "R"变成右type，
    /// "E"变成简单type，
    /// "H"变成复杂tpye，
    /// "."变成前一个type，
    /// 其他跳过。
    private func CustomizeSymbols(_ str: String) -> String {
        var label = ""
        var pre = ResultType.up.stringValue
        for i in 0..<str.count {
            switch str[i] {
            case "?": pre = ResultType.allVirusTypes.randomElement()!
            case "V": pre = ResultType.v.stringValue
            case "N": pre = ResultType.n.stringValue
            case "U": pre = ResultType.up.stringValue
            case "D": pre = ResultType.down.stringValue
            case "L": pre = ResultType.left.stringValue
            case "R": pre = ResultType.right.stringValue
            case "E": pre = ResultType.easyTypes.randomElement()!
            case "H": pre = ResultType.hardTypes.randomElement()!
            case ".": break
            default: continue
            }
            label += pre
        }
        return label
    }
    
    
    /** 将符号变成富文本显示 */
    private func updateAttributedLabel(){
        guard self.symbols != "" else {
            self.labelNode.attributedText = nil
            return
        }
        
        let attrStr = NSMutableAttributedString(string: self.symbols)
        
        //设置字体
        let fontAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .heavy)]
        attrStr.addAttributes(fontAttribute, range: NSRange(location: 0, length: attrStr.length))
        
        //每个标记设置不同的颜色
        for i in 0..<self.symbols.count {
            let color = (ResultType(stringValue: self.symbols[i])?.color) ?? .white
            let colorAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: color]
            attrStr.addAttributes(colorAttribute, range: NSRange(location: i, length: 1))
        }
        
        //更新富文本
        self.labelNode.attributedText = attrStr
    }
    
    // 自动移动
    private func runMoveAction() {
        guard self.loadSuccess, self.canMove else { return }
        self.specialTimer?.fireDate = Date()
        self.labelNode.run(.fadeAlpha(to: 1, duration: 0.6))
        
        self.removeAction(forKey: "autoMove")
        
        if self.autoMove == .toPoint {
            let action = SKAction.move(to: self.targetP, duration: TimeInterval(self.movetime ?? (self.distance / virusInfo.moveSpeed)))
            self.run(action, withKey: "autoMove")
        } else if self.autoMove == .toDir {
            guard let dir = self.movingDir else { return }
            let lenth = hypot(dir.dx, dir.dy)
            let totalLenth = hypot(UIScreen.main.bounds.width, UIScreen.main.bounds.height)*2
            let alpha = totalLenth/lenth
            let moveAction = SKAction.move(by: CGVector(dx: dir.dx*alpha, dy: dir.dy*alpha), duration: TimeInterval(totalLenth/self.virusInfo.moveSpeed))
            let moveAndOutAction = SKAction.sequence([moveAction,
                                                      .removeFromParent()])
            self.run(moveAndOutAction, withKey: "autoMove")
        }
    }
    
    // 手势识别后更新病毒剩余的virus箭头符号
    @objc private func gestureSign(noti: Notification) {
        guard self.loadSuccess == true,
              self.canMove == true,
            self.shouldDismiss == false,
            let sign = noti.userInfo?["sign"] as? String,
            ResultType.allVirusTypes.contains(sign) else { return }
        let firstSign = String(self.symbols.prefix(1))
        if firstSign == sign {
            self.symbols = String(self.symbols.dropFirst())
            //如果删除了第一个就先停止guid，后面一个标记在2s后出现guid
            self.guidGusture()
            if self.symbols != "" {
                self.maskNode.removeAction(forKey: "maskNodeFade")
                self.maskNode.alpha = 0.6
                self.maskNode.run(.fadeAlpha(to: 0, duration: 0.6), withKey: "maskNodeFade")
            }else{
                //添加分数
                GameCenter.shared.addScore(virus: self.virusName)
                self.shouldDismiss = true
            }
        }
        return
    }
    
    // 检测是否与Magician碰撞
    @objc private func atackMagician() {
        guard GameCenter.shared.gameState == .running,
              self.shouldDismiss == false else { return }
        
        if self.distance < self.virusInfo.radius + GameCenter.shared.magicianRadius {
            GameCenter.shared.AttackMagician()
            self.shouldDismiss = true
        }
    }
    
    @objc private func changeSpecialTimer() {
        if GameCenter.shared.gameState == .paused {
            self.specialTimer?.fireDate = .distantFuture
            self.atackTimer?.fireDate = .distantFuture
        } else if GameCenter.shared.gameState == .running {
            self.specialTimer?.fireDate = Date()
            self.atackTimer?.fireDate = Date()
        }
    }
    
    //MARK: - 初始化Virus
    private func setUpVirus(_ symbol: String? = nil) {
        self.name = virusName.rawValue
        self.virusInfo.setUpInfo(type: virusName)
        self.symbolCreater = symbol ?? self.virusInfo.symbols
        self.virusInfo.size = CGSize(width: self.virusInfo.size.width*self.virusScale, height: self.virusInfo.size.height*self.virusScale)
        self.virusInfo.radius = (self.virusInfo.radius+30)*self.virusScale - 30
        
        //初始化node
        textureNode = SKSpriteNode()
        self.addChild(textureNode)
        
        labelNode = SKLabelNode()
        labelNode.alpha = 0
        labelNode.position = CGPoint(x: 0, y: self.virusInfo.radius+15)
        labelNode.zPosition = 1
        self.addChild(labelNode)
        
        maskNode = SKShapeNode(circleOfRadius: self.virusInfo.size.width/2)
        maskNode.fillColor = UIColor.red
        maskNode.strokeColor = UIColor.clear
        maskNode.alpha = 0
        self.textureNode.addChild(maskNode)
        
        //设置size
        textureNode.size = self.virusInfo.size
        self.size = CGSize(width: self.virusInfo.size.width, height: self.virusInfo.size.height*1.2)
        
        // 设置图片，判断是gif还是图片
        if virusInfo.animated {
            setUpGif()
            stealth_greenBigEye()
            division_colorfulBeauty()
            childs_greenFatParents()
        } else { setUpPng() }
        
        //设置physicsBody
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.virusInfo.radius*0.9) // 照片尺寸大于实际显示的virus大小
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.mass = self.virusInfo.radius
        
        //设置symbols
        self.symbols = CustomizeSymbols(self.symbolCreater)
        self.specialTimer?.fireDate = .distantFuture
        self.runMoveAction()
    }
    
    /** 设置检测手势，攻击检测判断 */
    private func setUpNotifications() {
        //接收检测手势
        NotificationCenter.default.addObserver(self, selector: #selector(gestureSign(noti:)), name: NSNotification.Name("gestureSign"), object: nil)
        //暂停继续specialTimer
        NotificationCenter.default.addObserver(self, selector: #selector(changeSpecialTimer), name: NSNotification.Name("GameState_Changed"), object: nil)
        //攻击检测判断
        atackTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(atackMagician), userInfo: nil, repeats: true)
        atackTimer?.fire()
    }
    
    /** 所有symbol被清除后自动调用 */
    private func dismissAction() {
        backWard_King()
        if shouldDismiss {
            //播放声音
            GameAudio.share.playAudio(audio: .die)
            self.atackTimer?.invalidate() // 停止攻击魔术师检测
            self.specialTimer?.invalidate()
            self.removeAllActions()
            self.alpha = 1
            self.physicsBody = nil
            //取消移动动作，先放大，再爆炸，慢慢缩小，最后消失。
            let scaleBig = SKAction.scale(to: 1.3, duration: 0.3)
            scaleBig.timingMode = .easeIn
            self.labelNode.run(.fadeAlpha(to: 0, duration: 0.2))
            self.textureNode.removeAllActions()
            self.textureNode.run(.sequence([scaleBig,
                                            .setTexture(SKTexture(imageNamed: "png/star")),
                                            .run({self.blast_greenBomb()}),
                                            .fadeAlpha(to: 0, duration: 0.5),
                                            .run({
                                                self.revive_Queen()
                                                self.removeFromParent()
                                                //消灭时发送消息给guidVC
                                                NotificationCenter.default.post(Notification(name: Notification.Name("virus_Died")))
                                            })]))
        }
    }
    
    /** 游戏失败时调用 */
    func dieLost() {
        
        if !UIScreen.main.bounds.insetBy(dx: -200, dy: -200).contains(self.position){
            self.removeFromParent()
            return
        }
        
        //先取消所有动作
        self.atackTimer?.invalidate() // 停止攻击魔术师检测
        self.specialTimer?.invalidate()
        self.removeAllActions()
        self.textureNode.removeAllActions()
        self.alpha = 1
        self.physicsBody = nil
        self.labelNode.run(.fadeAlpha(to: 0, duration: 0.2))
        
        
        //t秒后，先放大，再爆炸，慢慢缩小，最后消失。
        let t = self.distance/200
        self.run(.sequence([.wait(forDuration: TimeInterval(t)),
                            .run({GameAudio.share.playAudio(audio: .die)}),
                            .scale(to: 1.3, duration: 0.5),
                            .removeFromParent()]))
    }
    
    
    //让labelNode闪烁,guidVC可以调用此方法
    func guidGusture() {
        guidTimer?.invalidate()
        NotificationCenter.default.post(Notification(name: Notification.Name("stop_GuidGesture")))
        guidTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            guard self.symbols != "", let t = ResultType(stringValue: self.symbols[0]) else { return }
            NotificationCenter.default.post(name: Notification.Name("add_GuidGesture"), object: nil, userInfo: ["symbolType" : t])
        })
    }
    
    func shakeVirus() {
        self.run(.sequence([
            .repeatForever(.sequence([.move(by: CGVector(dx: 0, dy: 30), duration: 1),
                                      .move(by: CGVector(dx: 0, dy: -30), duration: 1)]))
        ]), withKey: "shakeVirus")
    }
}


// MARK: - virus特殊技能
extension SKVirusNode {
    
    /*
    //自定义路径 virus1
    隐形 virus2
    爆炸 virus3
    生成小病毒 virus4
    分裂 virus6
    复活 virus7
    3条血，每条血结束后退 virus8
    */
    
    private func stealth_greenBigEye() {
        guard self.virusName == .greenBigEye else { return }
        
        var state = true
        self.specialTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            self.run(SKAction.fadeAlpha(to: state ? 0.1 : 0.9, duration: 2), withKey: "stealth_greenBigEye")
            state.toggle()
        }
        self.specialTimer?.fire()
    }
    
    private func blast_greenBomb() {
        guard self.virusName == .greenBomb,
              self.shouldDismiss == true else { return }
        self.textureNode.texture = nil
        NotificationCenter.default.post(name: NSNotification.Name("add_blast"), object: nil, userInfo: ["point": self.position])
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            NotificationCenter.default.post(Notification(name: Notification.Name("virus_Died")))
        }
        self.removeFromParent()
    }
    
    private func childs_greenFatParents() {
        guard self.virusName == .greenFatParents,
              self.shouldDismiss == false else { return }
        
        var child = 1
        
        self.specialTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            guard self.virusHierarchy <= 12 else {
                self.specialTimer?.invalidate()
                return
            }
            
            let de = atan((self.targetP.y-self.position.y) /
                            (self.targetP.x-self.position.x))
            
            var targetP = self.position
            targetP.x += 70 * cos(de)
            targetP.y += 70 * sin(de)
            targetP.x -= 100 * cos(de + CGFloat.pi/3*CGFloat(child/2)*((child % 2)==1 ? 1: -1))
            targetP.y -= 100 * sin(de + CGFloat.pi/3*CGFloat(child/2)*((child % 2)==1 ? 1: -1))
            child += 1
            
            let bigAction = SKAction.scale(to: 1.2, duration: 1)
            bigAction.timingMode = .easeIn
            let smallAction = SKAction.scale(to: 1, duration: 0.8)
            smallAction.timingMode = .easeOut
            self.run(.sequence([bigAction,
                                smallAction,
                                .run {
                                    NotificationCenter.default.post(name: NSNotification.Name("add_Virus"), object: nil, userInfo: ["virusInfo" : [VirusNames.normalVirus : 1], "point": targetP, "scale": self.virusScale])
                                }]))
            
            self.virusHierarchy += 1
        }
    }
    
    private func division_colorfulBeauty() {
        guard self.virusName == .colorfulBeauty,
              self.shouldDismiss == false else { return }
        
        var child = 1
        
        self.specialTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            guard self.virusHierarchy <= 3 else {
                self.specialTimer?.invalidate()
                return
            }
            
            let de = self.distance
            
            var targetP = self.position
            targetP.x += 70 * cos(de)
            targetP.y += 70 * sin(de)
            targetP.x -= 110 * cos(de + CGFloat.pi/3*(CGFloat(child)-2.5))
            targetP.y -= 110 * sin(de + CGFloat.pi/3*(CGFloat(child)-2.5))
            child += 1
            
            let bigAction = SKAction.scale(to: 1.6, duration: 1)
            bigAction.timingMode = .easeIn
            let smallAction = SKAction.scale(to: 1, duration: 0.2)
            smallAction.timingMode = .easeOut
            self.run(.sequence([bigAction,
                                smallAction,
                                .run {
                                    NotificationCenter.default.post(name: NSNotification.Name("add_Virus"), object: nil, userInfo: ["virusInfo" : [VirusNames.colorfulBeauty : 1], "point": targetP, "hierarchy" : self.virusHierarchy, "scale": self.virusScale])
                                }]))
            
            self.virusHierarchy += 1
        }
    }
    
    private func revive_Queen() {
        guard self.virusHierarchy == 1,
              self.virusName == .purpleQueen ,
              self.shouldDismiss == true else { return }
        
        NotificationCenter.default.post(name: NSNotification.Name("add_Virus"), object: nil, userInfo: ["virusInfo" : [VirusNames.purpleQueen : 1], "point": self.position, "hierarchy" : self.virusHierarchy, "scale": self.virusScale])
    }
    
    private func backWard_King() {
        guard self.virusName == .greenKing,
              self.virusHierarchy < 3,
              self.shouldDismiss == true else { return }
        
        self.shouldDismiss = false
        self.virusHierarchy += 1
        
        if self.autoMove == .noMove {
            let backAction = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width/2-200, y: UIScreen.main.bounds.height/2), duration: 0.3)
            
            self.run(backAction) {
                self.virusInfo.moveSpeed -= 2
                self.symbols = self.CustomizeSymbols(self.symbolCreater)
                self.run(.move(to: CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2), duration: TimeInterval(200 / self.virusInfo.moveSpeed)))
            }
            return
        }
        
        self.removeAction(forKey: "autoMove")
        let di = self.distance
        let tp = self.targetP
        let np = self.position
        let backDis: CGFloat = di < 180 ? 300 : 200
        let P = CGPoint(x: np.x - backDis*(tp.x-np.x)/di,
                        y: np.y - backDis*(tp.y-np.y)/di)
        
        let backAction = SKAction.move(to: P, duration: 0.3)
        
        backAction.timingMode = .easeOut
        self.run(backAction) {
            self.virusInfo.moveSpeed -= 2
            self.symbols = self.CustomizeSymbols(self.symbolCreater)
            self.runMoveAction()
        }
    }
}


enum MovingMode {
    case toPoint
    case toDir
    case noMove
}
