//
//  GameGuidViewController.swift
//  BookCore
//
//  Created by apple on 2021/4/13.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(BookCore_GameGuidViewController)
public class GameGuidViewController: UIViewController {
    
    let leftBackView = UIView()
    let nextPageView = UIView()
    let nextPageLabel = UILabel()
    let nextPageButton = UIButton()
    
    let infoLabel = UILabel()
    let bloodView = UIImageView()
    let minusButton = UIButton()
    let plusButton = UIButton()
    let bloodNum = UILabel()
    
    var gameScene: SKScene!
    var skView: SKView!
    var infoView: UILabel!
    var gestureView: GestureDrawView!
    var gestureGuidView: GestureGuidView!
    var virus: SKVirusNode?
    var userVirus = false
    var viewBounds = CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.height))
    
    let strs = ["Please draw the action above the virus to destroy the virus",
                "Please draw the action above the virus to destroy the virus",
                "When the arrow of the virus decreases, the virus turns red",
                "Gaining love when injured can increase blood!"]
    
    var virusNum = 0
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        virusNum = 0
        loadGameData()
        setUpView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GameAudio.share.backGroundAudio(audio: .back)
        addNewVirus()
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
        view.backgroundColor = UIColor.backFlesh
        
        leftBackView.frame = self.viewBounds
        leftBackView.backgroundColor = .white
        self.view.addSubview(leftBackView)
        
        self.skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.viewBounds.width, height: self.viewBounds.height*2/3)))
        gameScene = SKScene(size: self.skView.bounds.size)
        gameScene.backgroundColor = .white
        skView.presentScene(gameScene)
        leftBackView.addSubview(skView)
        
        infoView = UILabel(frame: CGRect(x: 0, y: view.bounds.height*2/3, width: self.viewBounds.width, height: self.viewBounds.height/3))
        infoView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        infoView.textAlignment = .center
        infoView.numberOfLines = 0
        infoView.font = UIFont(name: "PingFangSC-Semibold", size: 28)
        leftBackView.addSubview(infoView)
//        请画出病毒上方的动作来消灭病毒
        infoView.text = "Please draw the action above the virus to destroy the virus"
        
        // 引导手势view
        gestureGuidView = GestureGuidView(frame: viewBounds)
        leftBackView.addSubview(gestureGuidView)
        
        //添加手势识别
        gestureView = GestureDrawView(frame: self.viewBounds)
        leftBackView.addSubview(gestureView)
        let gameGesture = GameGestureRecognizer(target: self, action: #selector(GestureRespondent))
        gameGesture.delegate = self
        leftBackView.addGestureRecognizer(gameGesture)
        
        leftBackView.addSubview(nextPageView)
        nextPageView.isHidden = true
        nextPageView.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        nextPageView.frame = CGRect(x: UIScreen.main.bounds.width/10, y: UIScreen.main.bounds.height/6, width: UIScreen.main.bounds.width*3/10, height: UIScreen.main.bounds.height/3)
        nextPageView.layer.cornerRadius = 20
        nextPageView.layer.masksToBounds = true
        
        nextPageView.addSubview(nextPageButton)
        nextPageButton.frame = CGRect(x: UIScreen.main.bounds.width*3/20-90, y: UIScreen.main.bounds.height/3 - 65, width: 180, height: 60)
        nextPageButton.layer.cornerRadius = 15
        nextPageButton.layer.masksToBounds = true
        nextPageButton.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        nextPageButton.setTitle("Start Game", for: .normal)
        nextPageButton.addTarget(self, action: #selector(jumpToNextView), for: .touchDown)
        
        
        nextPageView.addSubview(nextPageLabel)
        nextPageLabel.frame = CGRect(x: 10, y: 10, width: UIScreen.main.bounds.width*3/10-20, height: UIScreen.main.bounds.height/3 - 70)
        nextPageLabel.numberOfLines = 0
        nextPageLabel.textAlignment = .center
        nextPageLabel.font = UIFont.systemFont(ofSize: 26)
        nextPageLabel.text = "Great! You already know how to eliminate the virus!"
        
        
        //添加Notification
        // 前一个virus死亡调用这个方法
        NotificationCenter.default.addObserver(self, selector: #selector(addNewVirus), name: NSNotification.Name(rawValue: "virus_Died"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addNewVirus), name: NSNotification.Name(rawValue: "blood_get"), object: nil)
        
        // 引导手势动作
        NotificationCenter.default.addObserver(self, selector: #selector(addGuidGesture(noti:)), name: NSNotification.Name(rawValue: "add_GuidGesture"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopGuidGesture), name: NSNotification.Name(rawValue: "stop_GuidGesture"), object: nil)
        
        
        infoLabel.frame = CGRect(x: UIScreen.main.bounds.width*3/4-200, y: UIScreen.main.bounds.height/3, width: 400, height: 100)
        infoLabel.text = "Congratulations on finding this easter egg,\n here you can set your maximum health(1-10)"
        infoLabel.attributedText = NSAttributedString(string: "Congratulations!\n You have found this easter egg,\n here you can set your maximum HP", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.red])
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        self.view.addSubview(infoLabel)
        
        bloodView.image = UIImage(named: "png/heart_1.png")
        bloodView.frame = CGRect(x: UIScreen.main.bounds.width*3/4-65, y: UIScreen.main.bounds.height/2, width: 130, height: 130)
        self.view.addSubview(bloodView)
        
        bloodNum.frame = CGRect(x: UIScreen.main.bounds.width*3/4-30, y: UIScreen.main.bounds.height/2+150, width: 60, height: 60)
        bloodNum.attributedText = NSAttributedString(string: "\(GameCenter.maxBlood)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.red])
        bloodNum.textAlignment = .center
        self.view.addSubview(bloodNum)
        
        let minusIcon = UIImage(systemName: "minus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large))
        minusButton.setImage(minusIcon?.withRenderingMode(.alwaysOriginal).withTintColor(.backPink), for: .normal)
        minusButton.frame = CGRect(x: UIScreen.main.bounds.width*3/4-120, y: UIScreen.main.bounds.height/2+150, width: 60, height: 60)
        minusButton.addTarget(self, action: #selector(minusBlood), for: .touchDown)
        self.view.addSubview(minusButton)
        
        let plusIcon = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large))
        plusButton.setImage(plusIcon?.withRenderingMode(.alwaysOriginal).withTintColor(.backPink), for: .normal)
        plusButton.frame = CGRect(x: UIScreen.main.bounds.width*3/4+60, y: UIScreen.main.bounds.height/2+150, width: 60, height: 60)
        plusButton.addTarget(self, action: #selector(plusBlood), for: .touchDown)
        self.view.addSubview(plusButton)
    }
    
    @objc func addNewVirus() {
        guard !self.userVirus else {
            trunToNextPage(); return
        }
        self.virusNum += 1
        var virusName: VirusNames?
        var symbol: String?
        if self.virusNum <= 4 {
            self.infoView.text = self.strs[self.virusNum-1]
        }
        switch self.virusNum {
        case 1: virusName = .normalVirus; symbol = "E"
        case 2: virusName = .yellowTail; symbol = "H"
        case 3: virusName = .redBigEye; symbol = "E.HHE."
        case 4: self.addBlood(); return
        default: trunToNextPage(); return
        }
        guard virusName != nil, symbol != nil else { return }
        virus = SKVirusNode(virusName: virusName!, moveMode: .noMove, scale: 1.6, symbol: symbol)
        virus!.position = CGPoint(x: self.viewBounds.width/2, y: self.viewBounds.width/3)
        virus!.shakeVirus()
        virus!.guidGusture()
        gameScene.addChild(virus!)
    }
    
    func addBlood() {
        let blood = SKBloodNode(move: false)
        blood.position = CGPoint(x: self.viewBounds.width/2, y: self.viewBounds.width/3)
        blood.guidGusture()
        gameScene.addChild(blood)
    }
    
    @objc func minusBlood() {
        guard GameCenter.maxBlood > 1 else { return }
        GameCenter.maxBlood -= 1
        bloodNum.attributedText = NSAttributedString(string: "\(GameCenter.maxBlood)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.red])
    }
    
    @objc func plusBlood() {

        guard GameCenter.maxBlood < 10 else { return }
        GameCenter.maxBlood += 1
        bloodNum.attributedText = NSAttributedString(string: "\(GameCenter.maxBlood)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .heavy), NSAttributedString.Key.foregroundColor: UIColor.red])
    }
    
    @objc func GestureRespondent(sender: GameGestureRecognizer) {
        gestureView.updatePath(p: sender.path, color: sender.result.color)
        if sender.state == .ended {
            gestureView.showResult(type: sender.result)
        }
    }
    
    @objc func addGuidGesture(noti: Notification) {
        guard let symbolType = noti.userInfo?["symbolType"] as? ResultType else { return }
        self.gestureGuidView.setPathAndDraw(type: symbolType)
    }
    
    @objc func stopGuidGesture() {
        self.gestureGuidView.stopDrawPath()
    }
    
    private func trunToNextPage() {
        self.nextPageView.isHidden = false
        PlaygroundPage.current.assessmentStatus = .pass(message: "Great! You already know how to eliminate the virus! [start Game](@next)")
    }
    
    @objc private func jumpToNextView() {
        PlaygroundPage.current.navigateTo(page: .next)
    }
}


extension GameGuidViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.virusNum > 4 { return false }
        return true
    }
}
