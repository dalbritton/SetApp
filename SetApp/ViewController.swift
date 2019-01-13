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
        //Adjust the state of some controls before they are drawn the first time
        for index in cardButtons.indices {
            cardButtons[index].isHidden = true
            cardButtons[index].layer.cornerRadius = 8
        }
        game.newGame()
        syncViewUsingModel()
    }
    
    @IBOutlet weak var dealButton: UIButton! { didSet { dealButton.layer.cornerRadius = 8 } }
    
    @IBAction func dealButton(_ sender: UIButton) {
        game.dealCards(numberOfCards: 3)
        statusLabel.text = ""
        setHintButtonTitle("Hint")
        syncViewUsingModel()
    }
    
    @IBOutlet weak var newGameButton: UIButton! { didSet { newGameButton.layer.cornerRadius = 8 } }
    
    @IBAction func newGameButton(_ sender: UIButton) {
        try! game.newGame()
        syncViewUsingModel()
    }
    
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let position = cardButtons.index(of: sender) {
            game.selectCard(atPosition: position)
            syncViewUsingModel()
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var hintButton: UIButton! { didSet { hintButton.layer.cornerRadius = 8 } }
    
    @IBAction func hintButton(_ sender: UIButton) {
        if hintButton.currentTitle == "Hint" {
            if let hints = game.generateHints() {
                var hintString = ""
                for index in hints.indices {
                    let selection: (card1:Int, card2: Int , card3:Int ) = hints[index]
                    hintString += "\(selection.card1+1),\(selection.card2+1),\(selection.card3+1)   "
                }
                statusLabel.text = hintString
                setHintButtonTitle("Hints (\(hints.count))")
            } else {
                statusLabel.text = "No Sets among the cards shown"
                setHintButtonTitle("Hints")
            }
        } else {
            setHintButtonTitle("Hint")
            statusLabel.text = ""
        }
        syncViewUsingModel()
    }
    
    private func setHintButtonTitle(_ text: String) {
        hintButton.setTitle(text, for:  UIControl.State.normal)
    }
    
    private func syncViewUsingModel() {
        //Show the cards that need to be shown, hiding all others
        for atPosition in 0..<game.board.count {
            if game.board[atPosition].card == nil {
                //No card to show
                cardButtons[atPosition].isHidden = true
            } else {
                //Sets the Face that will be displayed on the button for the Card at this position
                cardButtons[atPosition].setAttributedTitle(
                    buildCardFace(forCard: game.board[atPosition].card!), for: UIControl.State.normal)
                cardButtons[atPosition].titleLabel!.numberOfLines = 0
                //Adjust the border to highlight the position if needed
                switch game.board[atPosition].state {
                case .unselected: cardButtons[atPosition].layer.borderColor = view.backgroundColor!.cgColor
                case .selected: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                case .successful: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                case .failed: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
                cardButtons[atPosition].layer.borderWidth = 3
                cardButtons[atPosition].isHidden = false
                dealButton.isEnabled = game.cards.count > 0
                dealButton.titleLabel?.isEnabled = game.cards.count > 0
            }
        }
    }
    
    private func buildCardFace(forCard theCard: Card) -> NSAttributedString {
        var label = ""
        for _ in 1...theCard.pipCount!.rawValue {
            label += (label.count > 0 ? "\n" : "") + theCard.symbol!.rawValue
        }
        let attributes: [NSAttributedString.Key : Any] = [
            .strokeColor : theCard.color!.uiColor(),
            .strokeWidth : theCard.shading!.rawValue == "filled"
                || theCard.shading!.rawValue == "striped" ? -7 : 7,
            .foregroundColor : theCard.color!.uiColor().withAlphaComponent(theCard.shading!.rawValue == "striped" ? 0.15 : 1.0)
        ]
        return NSAttributedString(string:  label, attributes: attributes)
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
