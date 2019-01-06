//
//  Card.swift
//  SetApp
//
//  Created by davida on 1/1/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation
import UIKit

class Card {
    var cardIdentifier: Int?
    var symbol: Symbol
    var pipCount: PipCount
    var color: Color
    var shading: Shading
    var attributedString: NSAttributedString?
    
    init(cardIdentifier: Int?, symbol: Symbol, pipCount: PipCount, color: Color, shading: Shading) {
        self.cardIdentifier = cardIdentifier
        self.symbol = symbol
        self.pipCount = pipCount
        self.color = color
        self.shading = shading
    }
    
    enum Symbol: String {
        case triangle = "▲"
        case circle = "●"
        case square = "■"
        
        static var all = [Symbol.triangle, .circle, .square]
    }
    
    enum PipCount: Int {
        case one = 1
        case two = 2
        case three = 3
        
        static var all = [PipCount.one, .two, .three]
    }
    
    enum Color: String {
        case red
        case green
        case blue
        
        static var all = [Color.red, .green, .blue]
        
        func uiColor() -> UIColor {
            switch self.rawValue {
            case "red": return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            case "green": return  #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            case "blue": return  #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
            default: return  #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
            }
        }
    }
    
    enum Shading: String {
        case filled
        case striped
        case outlined
        
        static var all = [Shading.filled, .striped, .outlined]
    }
    
}
