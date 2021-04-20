//
//  VirusExtensions.swift
//  BookCore
//
//  Created by apple on 2021/2/22.
//

import UIKit

public enum VirusNames: String, CaseIterable {
    case yellowTail = "virus1"
    case greenBigEye = "virus2"
    case greenBomb = "virus3"
    case greenFatParents = "virus4"
    case redBigEye = "virus5"
    case colorfulBeauty = "virus6"
    case purpleQueen = "virus7"
    case greenKing = "virus8"
    case normalVirus = "virus9"
    
    var score: Int {
        switch self {
        case .yellowTail: return 2
        case .greenBigEye: return 4
        case .greenBomb: return 3
        case .greenFatParents: return 6
        case .redBigEye: return 6 //会增加2次分数
        case .colorfulBeauty: return 3
        case .purpleQueen: return 5 //会增加3次分数（每次清空都会增加一次）
        case .greenKing: return 5 //会增加3次分数
        case .normalVirus: return 1
        //        default: return 0
        }
    }
    
    var attributedIntroduction: NSAttributedString {
        let str = NSMutableAttributedString()
        switch self {
        case .yellowTail:
            //            黄尾，是一种小病毒,
            //            但是跑的比较快,
            //            有时候会在你不注意的时候
            //            向你冲过来，你可要小心哦！
            str.append(NSAttributedString(string: "Yellow Tail:\n I am small, but "))
            str.append(NSAttributedString(string: "fast", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: ".\n You must always be careful of being attacked."))
            break
        case .greenBigEye:
            //            绿眼，朋友们都知道我很低调，
            //            低调到你看不到我。
            //            希望你能在我出现的时候记住我的标记！
            str.append(NSAttributedString(string: "Green Eye:\n everyone knows that I am low-key. Sometimes you "))
            str.append(NSAttributedString(string: "couldn't see me", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: ".\n Hope you can remember my symbols when I appear."))
            break
        case .greenBomb:
            //            炸药桶，
            //            我的内心充满了能量，
            //            不要伤害我，
            //            不然我就要和你同归于尽！
            str.append(NSAttributedString(string: "Dynamite barrels:\n I am full of energy, do not try to hurt me,\n Otherwise "))
            str.append(NSAttributedString(string: "I will die with you", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: "!"))
            break
        case .greenFatParents:
            //            胖胖，我可是一个很称职的家长，
            //            我的孩子们都喜欢跟着我到处逛！
            str.append(NSAttributedString(string: "Fatty:\n I am a very competent parent,\n My "))
            str.append(NSAttributedString(string: "kids love to follow me around", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: "!"))
            break
        case .redBigEye:
            //            红眼，看看我的肌肉，
            //            谁能打得过我！
            str.append(NSAttributedString(string: "Red Eye:\n look at my muscles, No one can beat me!"))
            break
        case .colorfulBeauty:
            //            小精灵，想知道谁的笑容最灿烂，
            //            那一定是我了，
            //            我与我的伙伴们永不分离！
            str.append(NSAttributedString(string: "Elf:\n want to know who has the brightest smile?\n That must be me! I will "))
            str.append(NSAttributedString(string: "never be separated from my friends", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: "!"))
            break
        case .purpleQueen:
            //            我可是最尊贵的女王,
            //            重生让我永葆青春!
            str.append(NSAttributedString(string: "Queen:\n I am the most noble queen, "))
            str.append(NSAttributedString(string: "Rebirth", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: " keeps me young forever!"))
            break
        case .greenKing:
            //            你们好，我的子民们！
            //            整个病毒界都在我的掌控之中！
            str.append(NSAttributedString(string: "King:\n Hello, my people!\n The entire virus world is in my hand!"))
            break
        case .normalVirus:
            //            别看我只是小小的一个病毒,
            //            但我们冲锋陷阵的勇气可一点都不输别人.
            //            再悄悄告诉你们一个秘密:
            //            我们的国王有三次生命！
            //            什么？你们已经知道了！
            str.append(NSAttributedString(string: "NormalVirus:\n Although I am a small virus, our courage to attack is extremely high.\n Let me tell you another secret: "))
            str.append(NSAttributedString(string: "Our king has three lives", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]))
            str.append(NSAttributedString(string: "!\n what? You already know it!"))
            break
        }
        str.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .bold)], range: NSRange(location: 0, length: str.length))
        return str
    }
}

public enum ResultType: Int, CaseIterable {
    case unkonw = 0
    case left = 1
    case right = 2
    case up = 3
    case down = 4
    case v = 5
    case n = 6
    case circle = 7
    
    init?(stringValue str: String) {
        switch str {
        case "?": self = .unkonw
        case "←": self = .left
        case "→": self = .right
        case "↑": self = .up
        case "↓": self = .down
        case "〇": self = .circle
        case "v": self = .v
        case "ʌ": self = .n
        default: return nil
        }
    }
    
    var stringValue: String {
        switch self {
        case .unkonw: return "?"
        case .left: return "←"
        case .right: return "→"
        case .up: return "↑"
        case .down: return "↓"
        case .circle: return "〇"
        case .v: return "v"
        case .n: return "ʌ"
        }
    }
    
    var color: UIColor {
        switch self {
        case .unkonw: return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .left: return #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case .right: return #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        case .up: return #colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1)
        case .down: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .circle: return #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
        case .v: return #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
        case .n: return #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        }
    }
    
    static let easyTypes = ["←", "→", "↑", "↓"] //E
    static let hardTypes = ["v", "ʌ"] //H
    static let allVirusTypes = ["←", "→", "↑", "↓", "v", "ʌ"] //?
}

public extension Int {
    static func random(from start: Int = 0, to end: Int) -> Int {
        return Int(arc4random()) % (end-start+1) + start
    }
}

public extension String {
    subscript (i: Int) -> String {
        return "\(self[index(startIndex, offsetBy: i)])"
    }
}


public extension CGPoint {
    static func -(left: CGPoint, right: CGPoint) -> CGPoint {
        var point = CGPoint()
        point.x = left.x - right.x
        point.y = left.y - right.y
        return point
    }
}


public extension UIImage {
    static func virusImage(name virusName : VirusNames) -> UIImage {
        let path = Bundle.main.path(forResource: virusName.rawValue, ofType: "gif", inDirectory: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try? Data(contentsOf: url)
        let source =  CGImageSourceCreateWithData(gifData! as CFData, nil)!
        var i = 1
        if virusName == .colorfulBeauty { i=10 }
        let image = CGImageSourceCreateImageAtIndex(source, i, nil)!
        return UIImage(cgImage: image)
    }
}

public extension UIColor {
    static var backWhite: UIColor {
        if let backImage = UIImage(named: "png/back_white") {
            return UIColor(patternImage: backImage)
        }
        return .white
    }
    
    static var backBlue: UIColor {
        if let backImage = UIImage(named: "png/back_blue") {
            return UIColor(patternImage: backImage)
        }
        return .blue
    }
    
    static var backPink: UIColor {
        if let backImage = UIImage(named: "png/back_pink") {
            return UIColor(patternImage: backImage)
        }
        return .systemPink
    }
    
    static var backFlesh: UIColor {
        if let backImage = UIImage(named: "png/back_flesh") {
            return UIColor(patternImage: backImage)
        }
        return .systemPink
    }
}

