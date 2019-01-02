//
//  ViewController.swift
//  SetApp
//
//  Created by davida on 12/31/18.
//  Copyright © 2018 davida. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var game = SetGame()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dealButton.layer.cornerRadius = 8
        syncViewUsingModel()
    }
    
    @IBOutlet weak var dealButton: UIButton!
    @IBAction func dealButton(_ sender: UIButton) {
        game.dealCards(cardCount: 3)
        syncViewUsingModel()
    }

    @IBOutlet var cardButtons: [UIButton]!
    @IBAction func touchCard(_ sender: UIButton) {
        if let boardPosition = cardButtons.index(of: sender) {
            game.chooseCard(at: boardPosition)
            syncViewUsingModel()
        }
    }
    
    func syncViewUsingModel() {
        //Show the cards that need to be shown, hiding all others
        for at in 0..<24 {
            if game.boardPositions[at].card == nil {
                cardButtons[at].isHidden = true
            } else {
                let aCard = game.boardPositions[at].card!
                cardButtons[at].setAttributedTitle(aCard.attributedString, for: UIControl.State.normal)
                cardButtons[at].backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cardButtons[at].isHidden = false
            }
        }
    }
}

