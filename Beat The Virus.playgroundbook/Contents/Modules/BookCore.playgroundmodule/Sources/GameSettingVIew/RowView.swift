//
//  RowView.swift
//  BookCore
//
//  Created by apple on 2021/3/1.
//

import UIKit

public class RowView: UIView {
    static let StringNum = ["zero","first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth"]
    
    var num = 0 {
        didSet{
            guard num<10 else { return }
            self.titleLabel.text = "The" + RowView.StringNum[num] + "wave"
        }
    }
    var virusList: [VirusNames] = []
    private var scoreView = UIScrollView()
    private var virusSize = CGSize(width: 80, height: 80)
    private var titleLabel = UILabel()
    private var clearButton = UIButton()
    private var rowWidth: CGFloat!
    
    convenience init(num: Int, width: CGFloat = 800) {
        self.init()
        self.backgroundColor = UIColor.clear
        self.num = num
        self.rowWidth = width
        self.bounds = CGRect(x: 0, y: 0, width: width, height: 100)
        self.layer.masksToBounds = true
        
        titleLabel.backgroundColor = UIColor.backFlesh
        titleLabel.frame = CGRect(x: 0, y: 5, width: 130, height: 80)
        if num<10 {
            titleLabel.text = RowView.StringNum[num] + " wave"
        }
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        self.addSubview(titleLabel)
        titleLabel.layer.cornerRadius = 15
        titleLabel.layer.masksToBounds = true
        
        scoreView.backgroundColor = UIColor.backFlesh
        scoreView.tag = 20
        scoreView.frame = CGRect(x: 140, y: 0, width: rowWidth-140-90, height: 100)
        self.addSubview(scoreView)
        scoreView.showsHorizontalScrollIndicator = false
        scoreView.layer.cornerRadius = 20
        scoreView.layer.masksToBounds = true
        
        self.addSubview(clearButton)
        clearButton.backgroundColor = UIColor.backFlesh
        clearButton.tag = 20
        clearButton.frame = CGRect(x: rowWidth-85, y: 10, width: 80, height: 80)
        clearButton.layer.cornerRadius = 15
        clearButton.layer.masksToBounds = true
        clearButton.setTitle("clear", for: .normal)
        clearButton.addTarget(self, action: #selector(removeAll), for: .touchDown)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func insertVirus(name: VirusNames) {
        let virusView = UIImageView(frame: CGRect(x: CGFloat(virusList.count) * self.virusSize.width + 10, y: 10, width: 80, height: 80))
        virusView.tag = 30
        virusView.image = UIImage.virusImage(name: name)
        self.scoreView.addSubview(virusView)
        virusList.append(name)
        let newWidth = CGFloat(virusList.count) * self.virusSize.width + 20
        if self.scoreView.contentSize.width < newWidth {
            self.scoreView.contentSize.width = newWidth
        }
    }
    
    @objc func removeAll() {
        self.virusList.removeAll()
        for subV in self.scoreView.subviews {
            subV.removeFromSuperview()
        }
        self.scoreView.contentSize.width = self.scoreView.frame.width
    }
    
    func getVirusList() -> VirusRow? {
        var list = [VirusCreater]()
        for virus in virusList {
            list.append(VirusCreater(name: virus))
        }
        if list.count == 0 { return nil }
        return VirusRow(mode: .Wait, virus: list)
    }
}
