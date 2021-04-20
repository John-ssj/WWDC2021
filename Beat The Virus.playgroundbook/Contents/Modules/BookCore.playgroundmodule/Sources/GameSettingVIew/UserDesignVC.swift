//
//  UserDesignVC.swift
//  BookCore
//
//  Created by apple on 2021/3/1.
//

import UIKit
import PlaygroundSupport

public class UserDesignVC: UIViewController {
    
    var nilView = UILabel()
    var finishButton = UIButton()
    var scoreView = UIScrollView()
    var rowViews: [RowView] = []
    var movingImageView: UIImageView?
    var hintView = UIView()
    var hintLabel = UILabel()
    var hintButton = UIButton()
    var preRect: CGRect!
    
    var closeTimer: Timer?
    
    var showHint = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.backWhite
        
        // setUp virus images
        for i in 1...8 {
            let image = UIImage.virusImage(name: VirusNames(rawValue: "virus\(i)")!)
            let imageView = UIImageView(image: image)
            imageView.isUserInteractionEnabled = true
            imageView.backgroundColor = UIColor.backFlesh
            imageView.tag = i
            view.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.frame.width/11*CGFloat(i+1)),
                imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80),
                imageView.widthAnchor.constraint(equalToConstant: 80),
                imageView.heightAnchor.constraint(equalToConstant: 80)
            ])
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
        }
        
        view.addSubview(scoreView)
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scoreView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            scoreView.widthAnchor.constraint(equalToConstant: 1000),
            scoreView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.view.bounds.height/5)
        ])
        scoreView.backgroundColor = UIColor.backPink
        for i in 1...6 {
            let rowView = RowView(num: i, width: 800)
            rowView.frame = CGRect(x: 100, y: 20 + 120 * rowViews.count, width: 800, height: 100)
            scoreView.addSubview(rowView)
            self.rowViews.append(rowView)
            if scoreView.contentSize.height <= 120 * CGFloat(rowViews.count) {
                scoreView.contentSize.height += 120
            }
        }
        scoreView.contentSize.height += 50
        scoreView.layer.cornerRadius = 20
        scoreView.layer.masksToBounds = true
        
        // setUp hintView
//        拖动病毒到滑块内，来定制自己的关卡。
//        当前一个滑块的所有病毒被消灭后，下一个滑块中的病毒才会出现。
//        建议不要在同一个滑块内放太多病毒哦！
        hintLabel.text = """
Drag the virus into the slider to customize your own level.
After all viruses in the current slider are eliminated, the viruses in the next slider will appear.
It is recommended not to put too many viruses in the same slider!
"""
        hintLabel.lineBreakMode = .byWordWrapping
        hintLabel.numberOfLines = 0
        hintLabel.textAlignment = .left
        let vSize = hintLabel.sizeThatFits(CGSize(width: self.view.bounds.width/3, height: CGFloat(MAXFLOAT)))
        hintLabel.frame = CGRect(origin: CGPoint(x: 30, y: 20), size: vSize)
        
        hintView.backgroundColor = .white
        hintView.layer.cornerRadius = 20
        hintView.layer.masksToBounds = true
        hintView.frame = CGRect(x: self.view.bounds.width - vSize.width - 60 - 20, y: self.view.bounds.height - vSize.height - 40 - 20, width: vSize.width + 60, height: vSize.height + 40)
        self.view.addSubview(hintView)
        hintView.addSubview(hintLabel)
        
        self.view.addSubview(hintButton)
        hintButton.backgroundColor = .white
        hintButton.frame = CGRect(x: self.view.bounds.width-55, y: self.view.bounds.height-55, width: 30, height: 30)
        hintButton.layer.cornerRadius = 15
        hintButton.layer.masksToBounds = true
        hintButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.blue), for: .normal)
        hintButton.addTarget(self, action: #selector(hintToggle), for: .touchUpInside)
        
        
        view.addSubview(finishButton)
        finishButton.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            finishButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            finishButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -self.view.bounds.height/10),
            finishButton.widthAnchor.constraint(equalToConstant: 100),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        finishButton.layer.cornerRadius = 10
        finishButton.layer.masksToBounds = true
        finishButton.setTitle("Start!", for: .normal)
        finishButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        finishButton.addTarget(self, action: #selector(finishEditing), for: .touchDown)
    
        
        view.addSubview(nilView)
        nilView.frame = CGRect(x: UIScreen.main.bounds.width/2-200, y: UIScreen.main.bounds.height/2-60, width: 400, height: 120)
        nilView.alpha = 0
        nilView.backgroundColor = UIColor.backWhite
        nilView.attributedText = NSAttributedString(string: "All lists are empty!", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.red])
        nilView.textAlignment = .center
        nilView.layer.cornerRadius = 20
        nilView.layer.masksToBounds = true
        nilView.layer.borderWidth = 3
        nilView.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(Notification(name: Notification.Name("Start_Design")))
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.count == 1, let touchView = touches.first?.view else { return }
        if touchView.tag <= 8 {
            guard let imageView = touchView as? UIImageView,
                  let image = imageView.image else { return }
            movingImageView = UIImageView(image: image)
            movingImageView?.tag = imageView.tag
            movingImageView?.frame = imageView.frame
            preRect = imageView.frame
            view.addSubview(movingImageView!)
            UIView.animate(withDuration: 0.1) {
                self.movingImageView?.frame = imageView.frame.insetBy(dx: -30, dy: -30)
            }
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let imageView = movingImageView, let point = touches.first?.location(in: view) {
            UIView.animate(withDuration: 0.1) {
                let originPoint = CGPoint(x: point.x - imageView.bounds.size.width/2, y: point.y - imageView.bounds.size.height/2)
                imageView.frame = CGRect(origin: originPoint, size: imageView.bounds.size)
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let point = touches.first!.location(in: view)
        if let imageView = movingImageView,
           view.hitTest(point, with: nil)?.tag == 20,
           let rowView = view.hitTest(point, with: nil)?.superview as? RowView{
            let name = VirusNames(rawValue: "virus\(imageView.tag)")!
            rowView.insertVirus(name: name)
            self.movingImageView?.removeFromSuperview()
            self.movingImageView = nil
        } else {
            UIView.animate(withDuration: 0.2) {
                self.movingImageView?.frame = self.preRect
            } completion: { _ in
                self.movingImageView?.removeFromSuperview()
                self.movingImageView = nil
            }
        }
    }
    
    
    @objc func hintToggle() {
        self.showHint.toggle()
        if self.showHint {
            UIView.animate(withDuration: 0.8) {
                self.hintView.alpha = 1
                self.hintButton.setImage(nil, for: .normal)
            } completion: { _ in
                self.hintButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.blue), for: .normal)
            }
        } else {
            UIView.animate(withDuration: 0.8) {
                self.hintView.alpha = 0
                self.hintButton.setImage(nil, for: .normal)
            } completion: { _ in
                self.hintButton.setImage(UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.green), for: .normal)
            }
        }
    }
    
    func getAllVirusDic() -> [VirusRow] {
        var virusDic = [VirusRow]()
        for rowView in rowViews {
            if let virusRow = rowView.getVirusList(){
                virusDic.append(virusRow)
            }
        }
        return virusDic
    }
    
    @objc private func finishEditing() {
        let dic = getAllVirusDic()
        guard dic.count>0 else {
            closeTimer?.invalidate()
            nilView.alpha = 1
            closeTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                UIView.animate(withDuration: 0.5) {
                    self.nilView.alpha = 0
                }
            }
            GameAudio.share.backGroundAudio(audio: .error)
            return
        }
        GameCenter.shared.setVirusDic(dic)
        NotificationCenter.default.post(Notification(name: Notification.Name("StartGame")))
        self.dismiss(animated: true)
    }
}
