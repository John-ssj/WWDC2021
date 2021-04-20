//
//  GameCenter.swift
//  BookCore
//
//  Created by apple on 2021/3/28.
//

import UIKit
import PlaygroundSupport

public class GameCenter {
    
    // MARK: - init
    private init() {}
    
    static var shared: GameCenter = {
        let instance = GameCenter()
        instance.virusDic = VirusDic.Rank1
        return instance
    }()
    
    
    // MARK: - 关键变量
    /** 缩放比例 */
    var globalSclae: CGFloat {
        UIScreen.main.bounds.width/1024
    }
    /** 游戏状态 */
    var gameState: GameState = .start {
        didSet{
            GameStateChanged()
        }
    }
    /** 历史最高分数 */
    private var historyScore: Int = {
        if case let .string(num) = PlaygroundKeyValueStore.current["historyScore"] {
            return (Int(num)) ?? 5
        }
        return 5
    }()
    /** 目前分数 */
    private var presentScore: Int = 0 {
        didSet{
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Score_Changed")))
        }
    }
    var rankNum: Int = 0
    /** 最大血量 */
    static var maxBlood: Int = {
        if case let .string(blood) = PlaygroundKeyValueStore.current["maxBlood"] {
            return (Int(blood)) ?? 5
        }
        return 5
    }()
    {
        didSet{
            PlaygroundKeyValueStore.current["maxBlood"] = .string("\(maxBlood)")
        }
    }
    /** 目前血量 */
    private var presentBlood = GameCenter.maxBlood
    /** 魔术师在屏幕的位置 */
    var magicianPoint = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
    /** 魔术师半径 */
    var magicianRadius: CGFloat { 80*globalSclae }
    /** 现在运行的游戏关卡数据 */
    private var virusDic: [VirusRow]!
    /** 现在运行的是否是无尽关卡 */
    var isEndLess = false
    
    //MARK: - 游戏关卡设置
    //返回游戏关卡数据
    func getVirusDic() -> [VirusRow] {
        return self.virusDic
    }
    
    //设置游戏关卡数据
    func setVirusDic(_ dic: [VirusRow], endLess: Bool = false) {
        self.virusDic = dic
        self.isEndLess = endLess
    }
    
    //MARK: - Blood处理
    //返回血量
    func getBlood() -> Int {
        return self.presentBlood
    }
    
    //扣血
    func AttackMagician() {
        guard self.gameState == .running, self.presentBlood > 0 else { return }
        self.presentBlood -= 1
        if self.presentBlood == 0 { self.gameState = .lost }
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Blood_Changed"), object: nil, userInfo: ["attack" : true])
    }
    
    //加血
    func addBlood() {
        guard self.gameState == .running, self.presentBlood < GameCenter.maxBlood else { return }
        self.presentBlood += 1
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Blood_Changed")))
    }
    
    //MARK: - Score处理
    //返回历史最高分
    func getHistoryScore() -> Int {
        if self.isEndLess, presentScore > historyScore {
            historyScore = presentScore
            
            PlaygroundKeyValueStore.current["historyScore"] = .string("\(historyScore)")
        }
        return historyScore
    }
    
    //返回分数
    func getScore() -> Int {
        _ = getHistoryScore()
        return self.presentScore
    }
    
    //加分数
    func addScore(virus: VirusNames) {
        self.presentScore += virus.score
    }
    
    //MARK: - 游戏状态改变
    func GameStateChanged() {
        switch self.gameState {
        case .start: resetData()
        default: break
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "GameState_Changed")))
    }
    
    //重置游戏数据
    func resetData() {
        self.presentBlood = GameCenter.maxBlood
        self.presentScore = 0
    }
}

//MARK: - GameState定义
enum GameState: String {
    case start //重置各项系数,删除还在屏幕上的virus和blood
    case running //游戏运行过程
    case paused //游戏运行时暂停
    case win //游戏获胜,欢呼声和胜利动画,剩余的blood转化成score
    case lost //游戏失败,魔术师和virus从内到外一次爆炸
    case end //暂停一切动作
}
