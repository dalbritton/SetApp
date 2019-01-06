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
    lazy var cardDeck = CardDeck(numberOfCards: 81)
    
    //A board containing 24 positions upon which the game will be played
    lazy var board = Array(repeating: BoardPosition(), count: 24)
    
    var availableBoardPosition: Int? {
        //An empty (available) Position contains no Card
        for position in 0..<board.count {
            if board[position].card == nil {
                return position
            }
        }
        return nil
    }
    
    var selectedCardIndices: [Int] {
        //A BoardPosition must contain a Card in order to be selected
        return board.indices.filter {
            board[$0].card != nil && board[$0].isSelected
        }
    }
    
    func newGame() {
        //Create a new deck of 81 cards; shuffled into a random sequence
        cardDeck = CardDeck(numberOfCards: 81)
        
        //Create a board containing 24 positions upon which the game will be played
        board = Array(repeating: BoardPosition(), count: 24)
        
        //Deal 12 cards to start the game
        dealCards(numberOfCards: 12)
    }
    
    func dealCards(numberOfCards: Int) {
        for _ in 1...numberOfCards {
            if availableBoardPosition != nil && cardDeck.cards.count != 0 {
                board[availableBoardPosition!].card = cardDeck.draw()
            }
        }
    }
    
    func selectCard(atPosition: Int ) {
        if selectedCardIndices.count == 3 {
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
