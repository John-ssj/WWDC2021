//
//  RankData.swift
//  BookCore
//
//  Created by apple on 2021/3/1.
//

import UIKit

public class VirusDic {
    
    static let Rank0: [VirusRow] = [
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.4, toP: 0.6, symbol: "E"),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.4, toP: 0.6, symbol: "H"),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.4, toP: 0.6, symbol: "E"),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.4, toP: 0.6, symbol: "EE"),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.1, toP: 0.3, symbol: "HH")
        ]),
        VirusRow(group: true),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.4, toP: 0.6, symbol: "E."),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.1, toP: 0.4, symbol: "H."),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.6, toP: 0.9, symbol: "E."),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.4, toP: 0.6, symbol: "E."),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.6, toP: 0.8, symbol: "LH."),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.3, toP: 0.5, symbol: "LH."),
            VirusCreater(name: .normalVirus, dir: [.down], fromP: 0.5, toP: 0.7, symbol: "UH."),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.5, toP: 0.8, symbol: "UH."),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.1, toP: 0.1, symbol: "V"),
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.3, toP: 0.3, symbol: "L"),
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.6, toP: 0.6, symbol: "N"),
            VirusCreater(name: .normalVirus, dir: [.left], fromP: 0.8, toP: 0.8, symbol: "U"),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.1, toP: 0.1, symbol: "V"),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.3, toP: 0.3, symbol: "L"),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.6, toP: 0.6, symbol: "N"),
            VirusCreater(name: .normalVirus, dir: [.right], fromP: 0.8, toP: 0.8, symbol: "U"),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .redBigEye, dir: [.right], fromP: 0.5, toP: 0.6),
        ]),
    ]
    
    static let Rank1: [VirusRow] = [
        VirusRow(mode: .Wait, time: 1, normolNum: 2, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], symbol: "V"),
            VirusCreater(name: .normalVirus, dir: [.right], symbol: "L"),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 2, virus: [
            VirusCreater(name: .greenFatParents, dir: [.left]),
            VirusCreater(name: .greenBomb, dir: [.left]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 1, virus: [
            VirusCreater(name: .colorfulBeauty, dir: [.right]),
            VirusCreater(name: .colorfulBeauty, dir: [.right]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .greenBigEye, dir: [.right], fromP: 0.3, toP: 0.6),
            VirusCreater(name: .greenBigEye, dir: [.right], fromP: 0.1, toP: 0.2),
            VirusCreater(name: .greenBigEye, dir: [.down]),
            VirusCreater(name: .redBigEye, dir: [.left]),
        ]),
        VirusRow(fast: true),
        VirusRow(mode: .Time, time: 5, normolNum: 6, virus: [
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.left]),
            VirusCreater(name: .greenBomb, dir: [.left]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .purpleQueen, dir: [.right]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .colorfulBeauty, dir: [.left]),
        ]),
        VirusRow(mode: .Time, time: 3, normolNum: 2, virus: [
            VirusCreater(name: .greenFatParents, dir: [.left]),
        ]),
        VirusRow(mode: .Wait, time: 3, normolNum: 0, virus: [
            VirusCreater(name: .greenKing, dir: [.right]),
        ]),
    ]
    
    static let Rank2: [VirusRow] = [
        VirusRow(mode: .Wait, time: 1, normolNum: 4, virus: [
            VirusCreater(name: .normalVirus, dir: [.left]),
            VirusCreater(name: .normalVirus, dir: [.right]),
        ]),
        VirusRow(mode: .Time, time: 2, normolNum: 2, virus: [
            VirusCreater(name: .colorfulBeauty, dir: [.left]),
            VirusCreater(name: .colorfulBeauty, dir: [.left]),
            VirusCreater(name: .greenBomb, dir: [.left]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 1, virus: [
            VirusCreater(name: .redBigEye, dir: [.right]),
            VirusCreater(name: .greenBigEye, dir: [.right]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .greenBigEye, dir: [.right]),
            VirusCreater(name: .greenBigEye, dir: [.down]),
            VirusCreater(name: .redBigEye, dir: [.left], symbol: "LLV.EE"),
        ]),
        VirusRow(mode: .Time, time: 5, normolNum: 6, virus: [
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.left]),
            VirusCreater(name: .greenBomb, dir: [.left]),
        ]),
        VirusRow(mode: .Time, time: 5, normolNum: 0, virus: [
            VirusCreater(name: .purpleQueen, dir: [.right]),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .colorfulBeauty, dir: [.left]),
            VirusCreater(name: .greenBigEye, dir: [.right, .down], symbol: "EHE.")
        ]),
        VirusRow(mode: .Time, time: 3, normolNum: 2, virus: [
            VirusCreater(name: .greenFatParents, dir: [.left]),
            VirusCreater(name: .colorfulBeauty, dir: [.left]),
            VirusCreater(name: .greenBigEye, dir: [.right, .down])
        ]),
        VirusRow(mode: .Time, time: 7, normolNum: 0, virus: [
            VirusCreater(name: .greenKing, dir: [.right]),
        ]),
    ]
    
    static let Rank3: [VirusRow] = [
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .normalVirus, dir: [.left], symbol: "V"),
            VirusCreater(name: .normalVirus, dir: [.right], symbol: "L"),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .greenFatParents, dir: [.left]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .normalVirus, dir: [.down]),
            VirusCreater(name: .colorfulBeauty, dir: [.right, .left]),
            VirusCreater(name: .normalVirus, dir: [.right]),
        ]),
        VirusRow(mode: .Time, time: 4, normolNum: 0, virus: [
            VirusCreater(name: .greenBomb, dir: [.right, .left]),
            VirusCreater(name: .normalVirus),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .greenBigEye, dir: [.right, .left, .down]),
            VirusCreater(name: .greenBigEye, dir: [.left]),
            VirusCreater(name: .redBigEye, dir: [.left], symbol: "EEH.E."),
            VirusCreater(name: .normalVirus),
        ]),
        VirusRow(fast: true),
        VirusRow(mode: .Time, time: 9, normolNum: 0, virus: [
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .greenBomb, dir: [.right]),
            VirusCreater(name: .normalVirus),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .purpleQueen, dir: [.right], fromP: 0.2, toP: 0.7),
        ]),
        VirusRow(mode: .Wait, time: 1, normolNum: 0, virus: [
            VirusCreater(name: .colorfulBeauty, dir: [.left, .right]),
            VirusCreater(name: .greenBomb),
            VirusCreater(name: .greenBomb),
        ]),
        VirusRow(mode: .Time, time: 3, normolNum: 0, virus: [
            VirusCreater(name: .greenFatParents, dir: [.left, .right]),
            VirusCreater(name: .colorfulBeauty, dir: [.left, .right]),
            VirusCreater(name: .normalVirus),
        ]),
        VirusRow(mode: .Wait, time: 3, normolNum: 0, virus: [
            VirusCreater(name: .greenKing, dir: [.left], fromP: 0.2, toP: 0.7),
            VirusCreater(name: .normalVirus),
        ]),
    ]
    
    static func getPresentRow(dic: [VirusRow],at num: Int) -> VirusRow {
        let i = num % dic.count
        let addRowNum = Int(num/dic.count)
        var row = dic[i]
        for _ in 0..<addRowNum {
            if let v = dic[i].virus.randomElement(), v.name != .greenKing, v.name != .purpleQueen {
                row.virus.append(v)
            } else {
                row.virus.append(VirusCreater(name: VirusNames.allCases.randomElement()!))
            }
        }
        return row
    }
}


public struct VirusRow {
    var timeMode: TimeMode = .Wait
    var time: Int = 3
    var normolNum: Int = 0
    var groupV: Bool = false
    var fastV: Bool = false
    var virus: [VirusCreater]!
    
    init(mode: TimeMode = .Wait, time: Int = 3, normolNum: Int = 0, virus: [VirusCreater]? = []) {
        self.timeMode = mode
        self.time = time
        self.normolNum = normolNum
        self.virus = virus
    }
    
    init(group: Bool) {
        self.init()
        self.groupV = group
        self.virus = []
    }
    
    init(fast: Bool) {
        self.init()
        self.fastV = fast
        self.virus = []
    }
}

enum TimeMode {
    case Wait
    case Time
}

public struct VirusCreater {
    var name: VirusNames!
    var dir: [GameManager.Direction]?
    /** 0-1 */
    var fromP: CGFloat!
    var toP: CGFloat!
    var symbol: String?
    
    init(name: VirusNames, dir: [GameManager.Direction]? = nil, fromP: CGFloat = 0.1, toP: CGFloat = 0.9, symbol: String? = nil) {
        self.name = name
        self.dir = dir
        self.fromP = fromP
        self.toP = toP
        self.symbol = symbol
    }
}
