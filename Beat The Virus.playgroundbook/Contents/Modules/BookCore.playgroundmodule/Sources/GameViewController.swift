//
//  GameViewController.swift
//  BookCore
//
//  Created by apple on 2021/3/30.
//

import UIKit
import SpriteKit
import PlaygroundSupport

@objc(BookCore_GameViewController)
public class GameViewController: UIViewController {
    
    var gestureView = GestureDrawView(frame: UIScreen.main.bounds)
    
    // gameScene在class生成后加载。不然可能屏幕没有初始化，长宽互换。
    var gameScene: GameScene!
    var skView: SKView!
    lazy var settingView: GameSettingView = {
        let settingView = GameSettingView()
        settingView.viewDelegate = self
        return settingView
    }()
    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: self.view.bounds.width - 120, y: self.view.bounds.height - 100, width: 60, height: 60)
        button.tag = 10
        button.backgroundColor = UIColor.clear
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "png/pause")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        button.addTarget(self, action: #selector(setGame), for: .touchDown)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        GameCenter.shared.setVirusDic(VirusDic.Rank1)
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
        view.addSubview(settingButton)
        view.addSubview(settingView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameEnd), name: NSNotification.Name("GameState_Changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OpenDesignView), name: NSNotification.Name("OpenDesignView"), object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name("StartGame"), object: nil, queue: nil) { _ in
            self.gameScene.startGame()
        }
        
        let gameGesture = GameGestureRecognizer(target: self, action: #selector(GestureRespondent))
        gameGesture.delegate = self
        view.addGestureRecognizer(gameGesture)
    }
    
    @objc func setGame() {
        guard GameCenter.shared.gameState == .running else { return }
        GameCenter.shared.gameState = .paused
        
        self.settingView.open()
        self.gameScene?.pauseGame()
    }
    
    @objc func GameEnd() {
        guard GameCenter.shared.gameState == .end else { return }
        self.settingView.open()
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


extension GameViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        //手势识别，只在游戏运行时，对tag小于5的view生效
        guard GameCenter.shared.gameState == .running,
              !(touch.view is UIButton) else { return false }
        
        let tag = touch.view?.tag ?? 0
        return tag < 5
    }
}


extension GameViewController: SettingViewDelegate {
    func settingViewClose() {
        if GameCenter.shared.gameState == .paused {
            self.gameScene?.continueGame()
        }
    }
    
    func restartGame() {
        self.gameScene?.startGame()
    }
}
