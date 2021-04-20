//
//  VirusInfo.swift
//  BookCore
//
//  Created by apple on 2021/2/22.
//

import UIKit

public class VirusInfo: NSObject{
    
    private var InfoDic: [String: Any]!
    
    var type: VirusNames!
    var animated: Bool!
    var isEasy: Bool!
    var lenth: Int!
    var symbols: String!
    var size: CGSize!
    var radius: CGFloat!
    var duration: CGFloat!
    var moveSpeed: CGFloat!
    
    func setUpInfo(type: VirusNames) {
        self.type = type
        self.InfoDic = getJsonInfo()!
        self.size = getSize()
        self.animated = ((InfoDic["animated"] as! Int) == 1)
        self.isEasy = ((InfoDic["isEasy"] as! Int) == 1)
        self.lenth = (InfoDic["lenth"] as! Int)
        self.radius = (InfoDic["radius"] as! CGFloat) * GameCenter.shared.globalSclae
        self.duration = (InfoDic["duration"] as! CGFloat)
        self.moveSpeed = (InfoDic["moveSpeed"] as! CGFloat) * 6
        self.symbols = (InfoDic["symbols"] as! String)
    }
    
    private func getJsonInfo() -> [String: Any]? {
        guard let path = Bundle.main.path(forResource: "VirusInfo", ofType: "json") else {
            print("VirusInfo does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url),
              let jsonDic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any],
              let virusDic = jsonDic[self.type.rawValue] as? [String: Any] else {
            return nil
        }
        return virusDic
    }
    
    private func getSize() -> CGSize {
        let scale: CGFloat = 1.4*GameCenter.shared.globalSclae
        let sizeDic = (InfoDic["size"] as! [String: Any])
        let height = (sizeDic["hight"] as! CGFloat)
        let width = (sizeDic["width"] as! CGFloat)
        return CGSize(width: width*scale, height: height*scale)
    }
}
