//
//  VirusIntroductionVC.swift
//  BookCore
//
//  Created by apple on 2021/4/17.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(BookCore_VirusIntroductionVC)
public class VirusIntroductionVC: UIViewController {
    
    var gameScene: SKScene!
    var skView: SKView!
    // 底部按钮
    var pageButton: UIView!
    var pageLabel: UILabel!
    var preButton: UIButton!
    var nextButton: UIButton!
    // 点击继续手势
    var tapLabel: SKLabelNode!
    var tapGesture: UIGestureRecognizer!
    // 病毒聊天气泡
    var talkView: UIView!
    var talkLabel: UILabel!
    var bbLayer: BubbleLayer!
    // 前往下一页的button
    let nextPageView = UIView()
    let nextPageLabel = UILabel()
    let nextPageButton = UIButton()
    // 手势识别页面
    var gestureView: GestureDrawView!
    // 手势识别手势
    var gameGesture: GameGestureRecognizer!
    var virus: SKVirusNode?
    
    var pageNum = 1 // 1-9
    var virusName: VirusNames? {
        VirusNames(rawValue: "virus\(pageNum)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGameData()
        setUpView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GameAudio.share.backGroundAudio(audio: .back)
        addMainVirus()
    }
    
    public override func viewDidLayoutSubviews() {
        self.skView.frame = self.view.bounds
        gameScene.size = self.skView.bounds.size
        gestureView.frame = self.view.bounds
        tapLabel.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/5)
    }
    
    //MARK: - 异步加载游戏数据
    private func loadGameData() {
        DispatchQueue.global().async {
            _ = GameAudio.share
            _ = SKVirusNode.pngResource
            _ = SKVirusNode.gifResource
        }
    }
    
    func setUpView() {
        view.backgroundColor = .white
        
        self.skView = SKView(frame: self.view.bounds)
        gameScene = SKScene(size: self.skView.bounds.size)
        gameScene.backgroundColor = #colorLiteral(red: 0.5899409652, green: 0.7694094777, blue: 0.9999893308, alpha: 1)
        skView.presentScene(gameScene)
        view.addSubview(skView)
        
        // 病毒聊天气泡
        talkLabel = UILabel()
        talkView = UIView()
        view.addSubview(talkView)
        talkView.addSubview(talkLabel)
        talkView.backgroundColor = .white
        talkLabel.font = UIFont.systemFont(ofSize: 24)
//            UIFont(name: "PingFangSC-Semibold", size: 24)
        talkLabel.numberOfLines = 0
        talkLabel.lineBreakMode = .byWordWrapping
        talkLabel.textAlignment = .left
        reSizeText()
        
        // 手势识别view
        gestureView = GestureDrawView(frame: self.view.bounds)
        view.addSubview(gestureView)
        
        // 点击继续提示
        tapLabel = SKLabelNode()
        tapLabel.attributedText =  NSAttributedString(string: "Tap To Try!", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50, weight: .heavy),
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        ])
        tapLabel.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/5)
        tapLabel.zPosition = 2
        tapLabel.alpha = 0
        
        // 底部按钮
        pageButton = UIView()
        view.addSubview(pageButton)
        pageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            pageButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -70),
            pageButton.widthAnchor.constraint(equalToConstant: 200),
            pageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        pageButton.backgroundColor = #colorLiteral(red: 0.9223716855, green: 0.916888535, blue: 0.9265864491, alpha: 1)
        pageButton.alpha = 0.8
        pageButton.layer.cornerRadius = 20
        pageButton.layer.masksToBounds = true
        pageButton.isUserInteractionEnabled = true
        pageButton.tag = 10
        
        pageLabel = UILabel(frame: CGRect(x: 40, y: 0, width: 120, height: 50))
        pageLabel.text = "\(self.pageNum) of 9"
        pageLabel.textAlignment = .center
        pageButton.addSubview(pageLabel)
        
        preButton = UIButton(frame: CGRect(x: 10, y: 0, width: 30, height: 50))
        preButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        preButton.addTarget(self, action: #selector(trunToPrePage), for: .touchDown)
        preButton.tag = 10
        preButton.isEnabled = false
        pageButton.addSubview(preButton)
        
        nextButton = UIButton(frame: CGRect(x: 160, y: 0, width: 30, height: 50))
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.addTarget(self, action: #selector(trunToNextPage), for: .touchDown)
        nextButton.tag = 10
        pageButton.addSubview(nextButton)
        
        self.view.addSubview(nextPageView)
        nextPageView.isHidden = true
        nextPageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nextPageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextPageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nextPageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            nextPageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 2/5),
            nextPageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 2/5)
        ])
        nextPageView.layer.cornerRadius = 20
        nextPageView.layer.masksToBounds = true
        
        nextPageView.addSubview(nextPageButton)
        nextPageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextPageButton.centerXAnchor.constraint(equalTo: self.nextPageView.centerXAnchor),
            nextPageButton.bottomAnchor.constraint(equalTo: self.nextPageView.bottomAnchor, constant: -20),
            nextPageButton.widthAnchor.constraint(equalToConstant: 180),
            nextPageButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        nextPageButton.layer.cornerRadius = 15
        nextPageButton.layer.masksToBounds = true
        nextPageButton.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        nextPageButton.setTitle("Next Page", for: .normal)
        nextPageButton.addTarget(self, action: #selector(jumpToNextView), for: .touchDown)
        
        nextPageView.addSubview(nextPageLabel)
        nextPageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextPageLabel.topAnchor.constraint(equalTo: self.nextPageView.topAnchor),
            nextPageLabel.bottomAnchor.constraint(equalTo: self.nextPageButton.topAnchor, constant: -10),
            nextPageLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nextPageLabel.widthAnchor.constraint(equalTo: self.nextPageView.widthAnchor, multiplier: 0.8),
        ])
        nextPageLabel.numberOfLines = 0
        nextPageLabel.textAlignment = .center
        nextPageLabel.font = UIFont.systemFont(ofSize: 26)
        nextPageLabel.text = "You have mastered all the characteristics of the virus army, come and accept new challenges!"
        
        
        // 点击继续手势
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchToContinue))
        tapGesture.delegate = self
        // 添加手势识别
        gameGesture = GameGestureRecognizer(target: self, action: #selector(GestureRespondent))
        gameGesture.delegate = self
        
        //添加Notification
        // 前一个virus死亡调用这个方法
        NotificationCenter.default.addObserver(self, selector: #selector(virusDied), name: NSNotification.Name(rawValue: "virus_Died"), object: nil)
        // virus自动调用添加新病毒
        NotificationCenter.default.addObserver(self, selector: #selector(addVirus(noti:)), name: NSNotification.Name(rawValue: "add_Virus"), object: nil)
        // 添加爆炸病毒被消灭后留下阴影
        NotificationCenter.default.addObserver(self, selector: #selector(addBlast(noti:)), name: NSNotification.Name(rawValue: "add_blast"), object: nil)
    }
    
    private func reSizeText() {
        talkLabel.attributedText = self.virusName?.attributedIntroduction
        let virusW = self.virus?.frame.width ?? 80
        var Wsize = self.view.frame.width/2 - virusW/2 - 100
        if Wsize>350 { Wsize=350 }
        let Hsize = talkLabel.sizeThatFits(CGSize(width: Wsize, height: CGFloat(MAXFLOAT)))
        talkLabel.frame = CGRect(x: 40, y: 10, width: Wsize, height: Hsize.height)
        talkView.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2+(self.virus?.frame.width ?? 80)/2, y: self.view.bounds.height/2-talkLabel.bounds.height/2), size: CGSize(width: talkLabel.frame.width+45, height: talkLabel.frame.height+20))
        
        bbLayer = BubbleLayer(originalSize: self.talkView.bounds.size)
        bbLayer.arrowDirection = ArrowDirection.left.rawValue
        bbLayer.arrowHeight = 30   // 箭头的高度（长度）
        bbLayer.arrowWidth = 35   // 箭头的宽度
        bbLayer.arrowPosition = 0.5 // 箭头的相对位置
        bbLayer.arrowRadius = 3     // 箭头处的圆角半径
        bbLayer.cornerRadius = 30
        talkView.layer.mask = bbLayer.layer()
        talkView.alpha = 0
    }
    
    private func addBlastInfo() {
        let str = NSAttributedString(string: "Dynamite barrels will block your sight for 5 seconds after exploding", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)])
        talkLabel.attributedText = str
        let blastW: CGFloat = 150
        var Wsize = self.view.frame.width/2 - blastW - 100
        if Wsize>350 { Wsize=350 }
        let Hsize = talkLabel.sizeThatFits(CGSize(width: Wsize, height: CGFloat(MAXFLOAT)))
        talkLabel.frame = CGRect(x: 40, y: 10, width: Wsize, height: Hsize.height)
        talkView.frame = CGRect(origin: CGPoint(x: self.view.bounds.width/2+150, y: self.view.bounds.height/2-talkLabel.bounds.height/2), size: CGSize(width: talkLabel.frame.width+45, height: talkLabel.frame.height+20))
        
        bbLayer = BubbleLayer(originalSize: self.talkView.bounds.size)
        bbLayer.arrowDirection = ArrowDirection.left.rawValue
        bbLayer.arrowHeight = 30   // 箭头的高度（长度）
        bbLayer.arrowWidth = 35   // 箭头的宽度
        bbLayer.arrowPosition = 0.5 // 箭头的相对位置
        bbLayer.arrowRadius = 3     // 箭头处的圆角半径
        bbLayer.cornerRadius = 30
        talkView.layer.mask = bbLayer.layer()
        talkView.alpha = 0
    }
    
    func addMainVirus() {
        guard virusName != nil else { return }
        gameScene.removeAllChildren()
        virus = SKVirusNode(virusName: virusName!, moveMode: .noMove, scale: 1.6, canMove: false)
        virus!.position = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        virus!.shakeVirus()
        gameScene.addChild(virus!)
        
        self.reSizeText()
        UIView.animate(withDuration: 0.5) {
            self.talkView.alpha = 1
        }
        view.addGestureRecognizer(tapGesture)
        
        self.gameScene.addChild(tapLabel)
        tapLabel.alpha = 0.6
        tapLabel.run(.repeatForever(.sequence([.fadeAlpha(to: 1, duration: 0.3),
                                               .fadeAlpha(to: 0.6, duration: 1)])))
    }
    
    @objc func touchToContinue() {
        view.removeGestureRecognizer(tapGesture)
        view.addGestureRecognizer(gameGesture)
        
        self.virus?.canMove = true
        self.tapLabel.removeAllActions()
        self.tapLabel.run(.sequence([.fadeAlpha(to: 0, duration: 0.5),
                                     .removeFromParent()]))
        self.talkView.alpha = 0
    }

    @objc func virusDied() {
        //死亡，跳到下一页
        guard self.gameScene.children.filter({$0 is SKVirusNode}).isEmpty else { return }
        view.removeGestureRecognizer(gameGesture)
        
        if self.pageNum == 9 {
            self.nextPageView.isHidden = false
            return
        }
        trunToNextPage()
    }
    
    @objc private func trunToPrePage() {
        guard self.pageNum > 1 else { return }
        view.removeGestureRecognizer(gameGesture)
        self.pageNum -= 1
        self.pageLabel.text = "\(self.pageNum) of 9"
        if self.pageNum == 1 {
            self.preButton.isEnabled = false
        } else if self.pageNum == 8 {
            self.nextPageView.isHidden = true
            self.nextButton.isEnabled = true
        }
        self.addMainVirus()
    }
    
    @objc private func trunToNextPage() {
        guard self.pageNum < 9 else { return }
        view.removeGestureRecognizer(gameGesture)
        self.pageNum += 1
        self.pageLabel.text = "\(self.pageNum) of 9"
        if self.pageNum == 9 {
            self.nextButton.isEnabled = false
        } else if self.pageNum == 2 {
            self.preButton.isEnabled = true
        }
        self.addMainVirus()
    }
    
    @objc private func jumpToNextView() {
        PlaygroundPage.current.navigateTo(page: .next)
    }
    
    @objc func GestureRespondent(sender: GameGestureRecognizer) {
        gestureView.updatePath(p: sender.path, color: sender.result.color)
        if sender.state == .ended {
            gestureView.showResult(type: sender.result)
        }
    }
}


extension VirusIntroductionVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let tag = touch.view?.tag ?? 0
        return tag < 5
    }
}


extension VirusIntroductionVC {
    @objc private func addVirus(noti: Notification) {
        guard let virusList = noti.userInfo?["virusInfo"] as? [VirusNames: Int],
              var point = noti.userInfo?["point"] as? CGPoint else { return }
        let parentHierarchy = (noti.userInfo?["hierarchy"] as? Int) ?? 0
        
        for virus in virusList {
            for _ in 0..<virus.value{
                let virusNode = SKVirusNode(virusName: virus.key, moveMode: .noMove, scale: 1.2)
                virusNode.virusHierarchy += parentHierarchy
                let dir = CGFloat(Int.random(to: 360)) / 360 * 2 * CGFloat.pi
                point.x += 20 * cos(dir)
                point.y += 20 * sin(dir)
                virusNode.position = point
                virusNode.alpha = 0.2
                virusNode.setScale(0.5)
                GameAudio.share.playAudio(audio: .new)
                self.gameScene.addChild(virusNode)
                virusNode.run(SKAction.fadeAlpha(to: 1, duration: 0.6))
                virusNode.run(SKAction.scale(to: 1, duration: 2))
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
        self.gameScene.addChild(blastNode)
        self.addBlastInfo()
        UIView.animate(withDuration: 0.5) {
            self.talkView.alpha = 1
        }
        
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
}

