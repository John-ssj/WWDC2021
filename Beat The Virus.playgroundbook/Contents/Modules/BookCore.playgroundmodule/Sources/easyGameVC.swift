//
//  easyGameVC.swift
//  BookCore
//
//  Created by apple on 2021/4/18.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(BookCore_easyGameVC)
public class easyGameVC: UIViewController {
    
    var isWin = false {
        didSet {
            changeNextPageView()
        }
    }
    
    var gestureView = GestureDrawView(frame: UIScreen.main.bounds)
    
    // gameScene在class生成后加载。不然可能屏幕没有初始化，长宽互换。
    var gameScene: GameScene!
    var skView: SKView!
    let nextPageView = UIView()
    let nextPageLabel = UILabel()
    let nextPageButton = UIButton()
    lazy var settingView: easyStopView = {
        let settingView = easyStopView(frame: self.view.frame)
        settingView.viewDelegate = self
        return settingView
    }()
    lazy var pausedButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: self.view.bounds.width - 120, y: self.view.bounds.height - 100, width: 60, height: 60)
        button.tag = 10
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "png/pause")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        button.addTarget(self, action: #selector(pausedGame), for: .touchDown)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        GameCenter.shared.setVirusDic(VirusDic.Rank0)
        GameCenter.shared.rankNum = 0
        loadGameData()
        setUpGameView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.gameScene?.startGame()
    }
    
    //MARK: - 异步加载游戏数据
    private func loadGameData() {
        _ = GameAudio.share
        _ = SKVirusNode.pngResource
        _ = SKVirusNode.gifResource
    }
    
    func setUpGameView() {
        gameScene = GameScene(size: self.view.bounds.size)
        self.skView = SKView(frame: self.view.bounds)
        skView.presentScene(gameScene)
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        view.addSubview(skView)
        view.addSubview(gestureView)
        view.addSubview(pausedButton)
        view.addSubview(settingView)
        
        self.view.addSubview(nextPageView)
        nextPageView.isHidden = true
        nextPageView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        nextPageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextPageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nextPageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            nextPageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1/3),
            nextPageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1/3)
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
        nextPageButton.setTitle("Retry", for: .normal)
        nextPageButton.addTarget(self, action: #selector(jumpToNextView), for: .touchDown)
        
        
        nextPageView.addSubview(nextPageLabel)
        nextPageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextPageLabel.topAnchor.constraint(equalTo: self.nextPageView.topAnchor),
            nextPageLabel.bottomAnchor.constraint(equalTo: self.nextPageButton.topAnchor, constant: -10),
            nextPageLabel.centerXAnchor.constraint(equalTo: self.nextPageView.centerXAnchor),
            nextPageLabel.widthAnchor.constraint(equalTo: self.nextPageView.widthAnchor, multiplier: 0.8),
        ])
        nextPageLabel.numberOfLines = 0
        nextPageLabel.textAlignment = .center
        nextPageLabel.font = UIFont.systemFont(ofSize: 26)
        nextPageLabel.text = "Don't be discouraged, you will be victorious if you try it again!"
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameEnd), name: NSNotification.Name("GameState_Changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OpenDesignView), name: NSNotification.Name("OpenDesignView"), object: nil)
        
        let gameGesture = GameGestureRecognizer(target: self, action: #selector(GestureRespondent))
        gameGesture.delegate = self
        view.addGestureRecognizer(gameGesture)
    }
    
    func changeNextPageView() {
        guard self.isWin else { return }
        self.nextPageLabel.text = "Congratulations on passing the game. Let's see what new viruses appear!"
        self.nextPageButton.setTitle("Next Page", for: .normal)
    }
    
    @objc func jumpToNextView() {
        if self.isWin {
            PlaygroundPage.current.navigateTo(page: .next)
        } else {
            self.nextPageView.isHidden = true
            self.gameScene.startGame()
        }
    }
    
    @objc func pausedGame() {
        guard GameCenter.shared.gameState == .running else { return }
        GameCenter.shared.gameState = .paused
        
        self.pausedButton.isHidden = true
        self.settingView.open()
        self.gameScene?.pauseGame()
    }
    
    @objc func GameEnd() {
        if GameCenter.shared.gameState == .win { self.isWin = true }
        guard GameCenter.shared.gameState == .end else { return }
        self.nextPageView.isHidden = false
    }
    
    @objc func OpenDesignView() {
        let designVC = UserDesignVC()
        designVC.modalPresentationStyle = .fullScreen
        self.present(designVC, animated: true, completion: nil)
    }
    
    @objc func GestureRespondent(sender: GameGestureRecognizer) {
        gestureView.updatePath(p: sender.path, color: sender.result.color)
        if sender.state == .ended {
            gestureView.endDraw()
        }
    }
}


extension easyGameVC: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //手势识别，只在游戏运行时，对tag小于5的view生效
        guard GameCenter.shared.gameState == .running,
              !(touch.view is UIButton) else { return false }
        
        let tag = touch.view?.tag ?? 0
        return tag < 5
    }
}


extension easyGameVC: SettingViewDelegate {
    func settingViewClose() {
        if GameCenter.shared.gameState == .paused {
            self.pausedButton.isHidden = false
            self.gameScene?.continueGame()
        }
    }
    
    func restartGame() {
        self.pausedButton.isHidden = false
        self.gameScene?.startGame()
    }
}
