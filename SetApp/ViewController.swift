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
                game.board[atPosition].card!.initAttributedString()
                
                //Sets the Face that will be displayed on the button for the Card at this position
                cardButtons[atPosition].setAttributedTitle(game.board[atPosition].card!.attributedString, for: UIControl.State.normal)
                
                //Add a border to highlight the position if it is selected
                if game.board[atPosition].isSelected {
                    cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                    cardButtons[atPosition].layer.borderWidth = 3
                } else {
                    cardButtons[atPosition].layer.borderColor = view.backgroundColor!.cgColor
                    cardButtons[atPosition].layer.borderWidth = 3
                }
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
