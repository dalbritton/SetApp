//
//  ViewController.swift
//  SetApp
//
//  Created by davida on 12/31/18.
//  Copyright © 2018 davida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var game = SetApp()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        game.newGame()
        syncViewUsingModel()
    }
    
    @IBOutlet weak var dealButton: UIButton! {
        didSet {
            dealButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func dealButton(_ sender: UIButton) {
        game.dealCards(cardCount: 3)
        syncViewUsingModel()
    }
    
    @IBOutlet var cardButtons: [UIButton]! {
        didSet {
            for index in 0..<cardButtons.count {
                cardButtons[index].layer.cornerRadius = 8
            }
        }
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let position = cardButtons.index(of: sender) {
            game.selectCard(atPosition: position)
            syncViewUsingModel()
        }
    }
    
    func syncViewUsingModel() {
        //Show the cards that need to be shown, hiding all others
        for atPosition in 0..<24 {
            if game.board[atPosition].card == nil {
                cardButtons[atPosition].isHidden = true
            } else {
                var aCard = game.board[atPosition].card!
                //Build the NSAttributedString describing the Card's visual appearance
                if aCard.attributedString == nil {
                    //TODO: do this more efficiently
                    var symbolString = ""
                    for _ in 1...aCard.pipCount.rawValue {
                        symbolString += aCard.symbol.rawValue
                    }
                    let attributes: [NSAttributedString.Key : Any] = [
                        .strokeColor : aCard.color.uiColor(),
                        .strokeWidth : aCard.shading.rawValue == "filled" ? -5 : 5,
                        .foregroundColor : aCard.color.uiColor().withAlphaComponent(aCard.shading.rawValue == "striped" ? 0.15 : 1.0)
                    ]
                    aCard.attributedString = NSAttributedString(string: symbolString, attributes: attributes)
                }
                    
                cardButtons[atPosition].setAttributedTitle(aCard.attributedString, for: UIControl.State.normal)
                cardButtons[atPosition].isHidden = false
            }
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
