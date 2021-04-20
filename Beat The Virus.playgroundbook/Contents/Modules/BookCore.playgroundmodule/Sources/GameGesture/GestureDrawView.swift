//
//  MagicianNode.swift
//  BookCore
//
//  Created by apple on 2021/2/23.
//

import UIKit

public class GestureDrawView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var path: CGPath?
    private var pathColor: UIColor?
    private var timer: Timer?
    private let labelAlpha: CGFloat = 0.6
    private lazy var resultView: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 120, weight: .heavy)
        label.text = ResultType.unkonw.stringValue
        label.layer.cornerRadius = 40
        label.layer.masksToBounds = true
        label.layer.borderWidth = 3
        label.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1).cgColor
        label.layer.zPosition = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.heightAnchor.constraint(equalToConstant: 200)
        ])
        return label
    }()
    
    func updatePath(p: CGPath?, color: UIColor) {
        if (timer != nil) {
            timer?.fire()
            timer?.invalidate()
            timer = nil
        }
        path = p
        pathColor = color
        setNeedsDisplay()
    }
    
    func endDraw() {
        self.path = nil
        self.setNeedsDisplay()
    }
    
    func showResult(type result: ResultType) {
        resultView.textColor = result.color
        resultView.text = result.stringValue
        UIView.animate(withDuration: 0.2) {
            self.resultView.alpha = self.labelAlpha
        }
        self.path = nil
        self.setNeedsDisplay()
        timer = Timer(timeInterval: 0.5, repeats: false, block: { [self] _ in
            UIView.animate(withDuration: 0.2) {
                self.resultView.alpha = 0
            }
        })
        RunLoop.main.add(timer!, forMode: .default)
    }
    
    public override func draw(_ rect: CGRect) {
        guard let path = path else { return }
        // draw a thick yellow line for the user touch path
        let context = UIGraphicsGetCurrentContext()!
        context.addPath(path)
        context.setStrokeColor(self.pathColor?.cgColor ?? UIColor.yellow.cgColor)
        context.setLineWidth(10)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.strokePath()
    }
}
