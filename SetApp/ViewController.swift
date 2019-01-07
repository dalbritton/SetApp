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
        //Adjust the appearance of some controls before they are drawn
        for index in 0..<cardButtons.count {
            cardButtons[index].layer.cornerRadius = 8
        }
        game.newGame()
        syncViewUsingModel()
    }
    
    @IBOutlet weak var dealButton: UIButton! {
        didSet {
            dealButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func dealButton(_ sender: UIButton) {
        game.dealCards(numberOfCards: 3)
        syncViewUsingModel()
    }
    
    @IBOutlet weak var newGameButton: UIButton! {
        didSet {
            newGameButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
        game.newGame()
        syncViewUsingModel()
    }
    
    @IBOutlet var cardButtons: [UIButton]!
    
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
                //No card to show
                cardButtons[atPosition].isHidden = true
            } else {
                //Sets the Face that will be displayed on the button for the Card at this position
                cardButtons[atPosition].setAttributedTitle(
                    buildCardFace(for: game.board[atPosition].card!), for: UIControl.State.normal)
                
                //Adjust the border to highlight the position if needed
                switch game.board[atPosition].state {
                case .unselected: cardButtons[atPosition].layer.borderColor = view.backgroundColor!.cgColor
                case .selected: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                case .success: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                case .failure: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
                cardButtons[atPosition].layer.borderWidth = 3
                cardButtons[atPosition].isHidden = false
            }
        }
    }
}

func buildCardFace(for aCard: Card) -> NSAttributedString {
    //TODO: do this more efficiently
    var symbolString = ""
    for _ in 1...aCard.pipCount!.rawValue {
        symbolString += aCard.symbol!.rawValue
    }
    let attributes: [NSAttributedString.Key : Any] = [
        .strokeColor : aCard.color!.uiColor(),
        .strokeWidth : aCard.shading!.rawValue == "filled"
            || aCard.shading!.rawValue == "striped" ? -7 : 7,
        .foregroundColor : aCard.color!.uiColor().withAlphaComponent(aCard.shading!.rawValue == "striped" ? 0.15 : 1.0)
    ]
    return NSAttributedString(string:  symbolString, attributes: attributes)
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
