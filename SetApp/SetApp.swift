//
//  SetApp.swift
//  SetApp
//
//  Created by davida on 1/1/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation
import GameplayKit

class SetApp {
    //A deck of 81 cards; shuffled into a random sequence
    lazy var cardDeck = CardDeck(cardCount: 81)
    
    //A board containing 24 positions upon which the game will be played
    lazy var board = Array(repeating: BoardPosition(), count: 24)
    
    var availablePositions: [BoardPosition] {
        //An empty (available) Position contains no Card
        return board.filter { $0.card == nil }
    }
    
    var selectedPositions: [BoardPosition] {
        //A BoardPosition must contain a Card in order to be selected
        return board.filter {
            $0.card != nil && $0.isSelected
        }
    }
    
    func newGame() {
        //Create a new deck of 81 cards; shuffled into a random sequence
        cardDeck = CardDeck(cardCount: 81)
        
        //Create a board containing 24 positions upon which the game will be played
        board = Array(repeating: BoardPosition(), count: 24)
        
        //Deal 12 cards to start the game
        dealCards(cardCount: 12)
    }
    
    func dealCards(cardCount: Int) {
        for _ in 1...cardCount {
            if availablePositions.count != 0 && cardDeck.cards.count != 0 {
                var newPosition = availablePositions[0]
                newPosition.card = cardDeck.draw()
            }
        }
    }
    
    func selectCard(atPosition: Int ) {
        if selectedPositions.count == 3 {
            scoreSelectedCards()
        }
        
        //Select the BoardPosition if it contains a Card
        if board[atPosition].card != nil  {
            board[atPosition].isSelected = true
        }
    }
    
    func scoreSelectedCards() {
        
    }
    
} //SetApp
