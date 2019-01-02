//
//  SetGame.swift
//  SetApp
//
//  Created by davida on 1/1/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation
import GameplayKit

class SetGame {
    //Create a deck of 81 cards; an array shuffled into a random sequence
    lazy var cardDeck = cardFactory(cardCount: 81)
    
    //Create a board upon which the game will be played
    var boardPositions = [BoardPosition]()
    
    var availablePositions: [Int] {
        return boardPositions.indices.filter {boardPositions[$0].card == nil}
    }
    
    var selectedCards: [Int] {
        return cardDeck.indices.filter { cardDeck[$0].isSelected }
    }
    
    var availableCards: [Int] {
        return cardDeck.indices.filter { cardDeck[$0].isUndealt }
    }
    
    func chooseCard(at: Int ) {
        if selectedCards.count == 3 {
            scoreSelectedCards()
        }
        
        //Do nothing if there is no card at this position
        if boardPositions[at].card != nil  {
            var theCard = boardPositions[at].card!
            theCard.isSelected = true
        }
    }
    
    func scoreSelectedCards() {
        
    }
    
    enum shading {
        case filled
        case striped
        case outlined
    }
    
    func dealCards(cardCount: Int) {
        for _ in 1...cardCount {
            if availablePositions.count == 0 || availableCards.count == 0 { break }
            
            let newPosition = availablePositions[0]
            var newCard = cardDeck[availableCards[0]]
            boardPositions[newPosition].card = newCard
            newCard.isUndealt = false
        }
    }
    
    func cardFactory(cardCount: Int) -> [Card] {
        var cards = Array(repeating: Card(), count:cardCount)
        
        var symbols = ["▲", "●", "■"]
        var numbers = [1, 2, 3]
        var colors = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1),#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)]
        var shadings = ["filled", "striped", "outlined"]
        
        //Get a random list of cardNumbers to use as we create new Cards
        let shuffledSequence = GKShuffledDistribution(forDieWithSideCount: cardCount)
        for symbol in 0..<symbols.count {
            for number in 0..<numbers.count {
                for color in 0..<colors.count {
                    for shading in 0..<shadings.count {
                        //TODO: do this more efficiently
                        var symbolString = ""
                        for _ in 1...numbers[number] {
                            symbolString += symbols[symbol]
                        }
                        
                        let attributes: [NSAttributedString.Key : Any] = [
                            .strokeColor : colors[color],
                            .strokeWidth : shadings[shading] == "filled" ? -5 : 5,
                            .foregroundColor : colors[color].withAlphaComponent(shadings[shading] == "striped" ? 0.15 : 1.0)
                        ]
                        //Point to a shuffled position for this card to occupy
                        let cardPosition = shuffledSequence.nextInt()
                        cards[cardPosition].cardIdentifier = cardPosition
                        cards[cardPosition].attributedString = NSAttributedString(string: symbolString, attributes: attributes)
                    }
                }
            }
        }
        return cards
    }
}
