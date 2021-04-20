//
//  easyStopView.swift
//  BookCore
//
//  Created by apple on 2021/4/18.
//

import UIKit

public class easyStopView: UIView {
    
    var viewDelegate: SettingViewDelegate?
    private var pausedLabel = UILabel()
    private var continueButton = UIButton()
    private var restartButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        self.alpha = 0
        
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        self.addSubview(pausedLabel)
        pausedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pausedLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            pausedLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -100),
            pausedLabel.widthAnchor.constraint(equalToConstant: 500),
            pausedLabel.heightAnchor.constraint(equalToConstant: 100),
        ])
        pausedLabel.text = "Game Paused"
//        pausedLabel.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        pausedLabel.font = UIFont.systemFont(ofSize: 80)
        pausedLabel.textAlignment = .center
        
        self.addSubview(restartButton)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.topAnchor.constraint(equalTo: self.pausedLabel.bottomAnchor, constant: 20),
            restartButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -100),
            restartButton.widthAnchor.constraint(equalToConstant: 120),
            restartButton.heightAnchor.constraint(equalToConstant: 120)
        ])
        let restartIcon = UIImage(systemName: "stop.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: .bold, scale: .large))
        restartButton.setImage(restartIcon?.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchDown)
        
        self.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: self.pausedLabel.bottomAnchor, constant: 20),
            continueButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 100),
            continueButton.widthAnchor.constraint(equalToConstant: 120),
            continueButton.heightAnchor.constraint(equalToConstant: 120)
        ])
        let continueIcon = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 120, weight: .bold, scale: .large))
        continueButton.setImage(continueIcon?.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
        continueButton.addTarget(self, action: #selector(closeSelf), for: .touchDown)
    }
    
    func open() {
        //更新记录
        self.continueButton.isHidden = (GameCenter.shared.gameState == .end)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5) {
            self.alpha = 1
        }
    }
    
    @objc private func closeSelf() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
        self.viewDelegate?.settingViewClose()
    }
    
    @objc private func restartGame() {
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0
        }
        self.viewDelegate?.restartGame()
    }
}
