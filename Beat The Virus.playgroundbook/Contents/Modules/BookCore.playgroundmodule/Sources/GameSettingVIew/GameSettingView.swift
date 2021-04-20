//
//  GameSettingView.swift
//  BookCore
//
//  Created by apple on 2021/2/23.
//

import UIKit

public class GameSettingView: UIView {
    
    var viewDelegate: SettingViewDelegate?
    private var settingView = UIView()
    private var continueButton = UIButton()
    private var rankLabel = UILabel()
    private var rankSelecter = UIScrollView()
    private var endLessLabel = UILabel()
    private var DesignButton = UIButton()
    private var restartButton = UIButton()
    private var preButton = UIButton()
    private var nextButton = UIButton()
    private var rankNum: Int { Int((self.rankSelecter.contentOffset.x)/600) }
    private let rankName = ["Skyland", "Ancient Forest", "Ice Mountain"]
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.isHidden = true
        
        setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        self.addSubview(settingView)
        settingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            settingView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            settingView.widthAnchor.constraint(equalToConstant: 800),
            settingView.heightAnchor.constraint(equalToConstant: 550)
        ])
        self.settingView.layer.borderWidth = 3
        self.settingView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        self.settingView.layer.cornerRadius = 30
        self.settingView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        settingView.addSubview(rankLabel)
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankLabel.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor),
            rankLabel.topAnchor.constraint(equalTo: self.settingView.topAnchor, constant: 10),
            rankLabel.widthAnchor.constraint(equalToConstant: 500),
            rankLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        rankLabel.text = "Tap The Picture To Change Level"
        rankLabel.textColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
        rankLabel.textAlignment = .center
        rankLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        
        settingView.addSubview(rankSelecter)
        rankSelecter.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rankSelecter.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor),
            rankSelecter.topAnchor.constraint(equalTo: self.settingView.topAnchor, constant: 70),
            rankSelecter.widthAnchor.constraint(equalToConstant: 700),
            rankSelecter.heightAnchor.constraint(equalToConstant: 400)
        ])
        rankSelecter.backgroundColor = .clear
        rankSelecter.layer.cornerRadius = 30
        rankSelecter.layer.masksToBounds = true
        rankSelecter.contentSize = CGSize(width: 700*3, height: 340)
        rankSelecter.isPagingEnabled = true
        rankSelecter.delegate = self
        rankSelecter.showsHorizontalScrollIndicator = false
        rankSelecter.isUserInteractionEnabled = true
        for i in 0..<3 {
            let rankView = UIButton(frame: CGRect(x: 20+i*700, y: 10, width: 660, height: 380))
            rankView.layer.cornerRadius = 30
            rankView.layer.masksToBounds = true
            rankView.setImage(UIImage(named: "png/background\(i).jpg")?.withRenderingMode(.alwaysOriginal), for: .normal)
            rankView.tag = i
            rankView.addTarget(self, action: #selector(selectGame), for: .touchDown)
            rankSelecter.addSubview(rankView)
            
            let rankName = UILabel(frame: CGRect(x: 230, y: 20, width: 200, height: 40))
            rankName.backgroundColor = #colorLiteral(red: 0.8161776662, green: 1, blue: 0.8054469824, alpha: 1)
            rankName.layer.cornerRadius = 15
            rankName.layer.masksToBounds = true
            rankName.layer.borderWidth = 3
            rankName.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            rankName.text = self.rankName[i]
            rankName.textColor = #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.09019608051, alpha: 1)
            rankName.textAlignment = .center
            rankName.font = UIFont.systemFont(ofSize: 30)
            rankView.addSubview(rankName)
            if i == 2 {
                endLessLabel.frame = CGRect(x: 175, y: 80, width: 350, height: 80)
                endLessLabel.backgroundColor = #colorLiteral(red: 0.8161776662, green: 1, blue: 0.8054469824, alpha: 1)
                endLessLabel.layer.cornerRadius = 15
                endLessLabel.layer.masksToBounds = true
                endLessLabel.layer.borderWidth = 3
                endLessLabel.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                endLessLabel.text = "This is an endless rank!\n Highest Score:\(GameCenter.shared.getHistoryScore())!"
                endLessLabel.numberOfLines = 2
                endLessLabel.textColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
                endLessLabel.textAlignment = .center
                endLessLabel.font = UIFont.systemFont(ofSize: 30)
                rankView.addSubview(endLessLabel)
            }
        }
        
        settingView.addSubview(preButton)
        preButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preButton.centerYAnchor.constraint(equalTo: self.rankSelecter.centerYAnchor),
            preButton.trailingAnchor.constraint(equalTo: self.rankSelecter.leadingAnchor, constant: -5),
            preButton.widthAnchor.constraint(equalToConstant: 40),
            preButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        let preIcon = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large))
        preButton.setImage(preIcon?.withRenderingMode(.alwaysOriginal), for: .normal)
        preButton.addTarget(self, action: #selector(trunToPreRank), for: .touchDown)
        preButton.isEnabled = !(rankNum == 0)
        
        settingView.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.centerYAnchor.constraint(equalTo: self.rankSelecter.centerYAnchor),
            nextButton.leadingAnchor.constraint(equalTo: self.rankSelecter.trailingAnchor, constant: 5),
            nextButton.widthAnchor.constraint(equalToConstant: 40),
            nextButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        let nextIcon = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large))
        nextButton.setImage(nextIcon?.withRenderingMode(.alwaysOriginal), for: .normal)
        nextButton.addTarget(self, action: #selector(trunToNextRank), for: .touchDown)
        nextButton.isEnabled = !(rankNum == 2)
        
        settingView.addSubview(restartButton)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: rankSelecter.bottomAnchor, constant: 15),
            restartButton.bottomAnchor.constraint(equalTo: self.settingView.bottomAnchor, constant: -15),
            restartButton.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor, constant: -160),
            restartButton.widthAnchor.constraint(equalToConstant: 140)
        ])
        restartButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        restartButton.layer.cornerRadius = 10
        restartButton.layer.masksToBounds = true
        restartButton.setTitle("Restart", for: .normal)
        restartButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchDown)
        
        
        settingView.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: rankSelecter.bottomAnchor, constant: 15),
            continueButton.bottomAnchor.constraint(equalTo: self.settingView.bottomAnchor, constant: -15),
            continueButton.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 140)
        ])
        continueButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        continueButton.layer.cornerRadius = 10
        continueButton.layer.masksToBounds = true
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        continueButton.addTarget(self, action: #selector(closeSelf), for: .touchDown)
        
        settingView.addSubview(DesignButton)
        DesignButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            DesignButton.topAnchor.constraint(equalTo: rankSelecter.bottomAnchor, constant: 15),
            DesignButton.bottomAnchor.constraint(equalTo: self.settingView.bottomAnchor, constant: -15),
            DesignButton.centerXAnchor.constraint(equalTo: self.settingView.centerXAnchor, constant: 160),
            DesignButton.widthAnchor.constraint(equalToConstant: 140)
        ])
        DesignButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        DesignButton.layer.cornerRadius = 10
        DesignButton.layer.masksToBounds = true
        DesignButton.setTitle("Design", for: .normal)
        DesignButton.titleLabel?.font = UIFont.systemFont(ofSize: 25)
        DesignButton.addTarget(self, action: #selector(OpenDesignView), for: .touchDown)
    }
    
    @objc private func trunToPreRank() {
        preButton.isEnabled = !(rankNum == 0)
        nextButton.isEnabled = !(rankNum == 2)
        if rankNum > 0 {
            UIView.animate(withDuration: 0.5) { [self] in
                self.rankSelecter.contentOffset.x -= 700
                preButton.isEnabled = !(rankNum == 0)
                nextButton.isEnabled = !(rankNum == 2)
            }
        }
    }
    
    @objc private func trunToNextRank() {
        preButton.isEnabled = !(rankNum == 0)
        nextButton.isEnabled = !(rankNum == 2)
        if rankNum < 2 {
            UIView.animate(withDuration: 0.5) { [self] in
                self.rankSelecter.contentOffset.x += 700
                preButton.isEnabled = !(rankNum == 0)
                nextButton.isEnabled = !(rankNum == 2)
            }
        }
    }
    
    func open() {
        self.isHidden = false
        if self.settingView.center.y != self.center.y - UIScreen.main.bounds.height {
            self.settingView.center.y -= UIScreen.main.bounds.height
        }
        //更新记录
        endLessLabel.text = "This is an endless level!\n Highest Score:\(GameCenter.shared.getHistoryScore())!"
        //如果是end状态，不能直接关闭settingView
        self.continueButton.isHidden = (GameCenter.shared.gameState == .end)
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5) {
            self.settingView.center.y += UIScreen.main.bounds.height
        }
    }
    
    @objc private func closeSelf() {
        UIView.animate(withDuration: 0.5) {
            self.settingView.center.y -= UIScreen.main.bounds.height
        } completion: { _ in
            self.isHidden = true
        }
        
        self.viewDelegate?.settingViewClose()
    }
    
    @objc private func restartGame() {
        UIView.animate(withDuration: 0.5) {
            self.settingView.center.y -= UIScreen.main.bounds.height
        } completion: { _ in
            self.isHidden = true
        }
        
        self.viewDelegate?.restartGame()
    }
    
    @objc private func OpenDesignView() {
        self.settingView.center.y -= UIScreen.main.bounds.height
        self.isHidden = true
        
        NotificationCenter.default.post(Notification(name: Notification.Name("OpenDesignView")))
    }
    
    
    @objc private func selectGame() {
        var rank = VirusDic.Rank1
        
        switch rankNum {
        case 0: rank = VirusDic.Rank1
        case 1: rank = VirusDic.Rank2
        case 2: rank = VirusDic.Rank3
        default: break
        }
        GameCenter.shared.rankNum = rankNum
        GameCenter.shared.setVirusDic(rank, endLess: (rankNum == 2))
        self.restartGame()
    }
}

extension GameSettingView: UIScrollViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [self] _ in
            preButton.isEnabled = !(rankNum == 0)
            nextButton.isEnabled = !(rankNum == 2)
        }
    }
}

protocol SettingViewDelegate {
    func settingViewClose()
    func restartGame()
}
