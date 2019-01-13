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
        statusLabel.text = ""
        setHintButtonTitle("Hint")
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
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var hintButton: UIButton! {
        didSet {
            hintButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func hintButton(_ sender: UIButton) {
        if hintButton.currentTitle == "Hint" {
            let hints = game.generateHints()
            if hints.count == 0 {
                statusLabel.text = "No Sets among the cards shown"
                setHintButtonTitle("Hints")
            } else {
                var hintString = ""
                for index in 0..<hints.count {
                    let aSelection = hints[index]
                    hintString += "\(aSelection[0].boardPosition+1),\(aSelection[1].boardPosition+1),\(aSelection[2].boardPosition+1)   "
                }
                statusLabel.text = hintString
                setHintButtonTitle("Hints (\(hints.count))")
            }
        } else {
            setHintButtonTitle("Hint")
            statusLabel.text = ""
        }
        syncViewUsingModel()
    }
    
    func setHintButtonTitle(_ text: String) {
        hintButton.setTitle(text, for:  UIControl.State.normal)
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
                    buildCardFace(forCard: game.board[atPosition].card!), for: UIControl.State.normal)
                cardButtons[atPosition].titleLabel!.numberOfLines = 0
                //Adjust the border to highlight the position if needed
                switch game.board[atPosition].state {
                case .unselected: cardButtons[atPosition].layer.borderColor = view.backgroundColor!.cgColor
                case .selected: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                case .success: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
                case .failure: cardButtons[atPosition].layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
                }
                cardButtons[atPosition].layer.borderWidth = 3
                cardButtons[atPosition].isHidden = false
                dealButton.isEnabled = game.cards.count > 0
                dealButton.titleLabel?.isEnabled = game.cards.count > 0
            }
        }
    }
}

func buildCardFace(forCard aCard: Card) -> NSAttributedString {
    var label = ""
    for _ in 1...aCard.pipCount!.rawValue {
        label += (label.count > 0 ? "\n" : "") + aCard.symbol!.rawValue
    }
    let attributes: [NSAttributedString.Key : Any] = [
        .strokeColor : aCard.color!.uiColor(),
        .strokeWidth : aCard.shading!.rawValue == "filled"
            || aCard.shading!.rawValue == "striped" ? -7 : 7,
        .foregroundColor : aCard.color!.uiColor().withAlphaComponent(aCard.shading!.rawValue == "striped" ? 0.15 : 1.0)
    ]
    return NSAttributedString(string:  label, attributes: attributes)
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
