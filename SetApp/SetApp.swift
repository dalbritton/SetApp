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
    var cardDeck: CardDeck?
    
    //A board containing 24 positions upon which the game will be played
    var board = [BoardPosition]()
    
    var availableBoardPosition: Int? {
        //An empty (available) Position contains no Card
        for position in 0..<board.count {
            if board[position].card == nil {
                return position
            }
        }
        return nil
    }
    
    func selectedSet() -> [Int] {
        //BoardPositions containing a Card and being in "selected" states
        var retValues = [Int]()
        for index in 0..<24 {
            if board[index].card != nil && board[index].state != .unselected {
                retValues.append(index)
            }
        }
        return retValues
    }
    
    var failureSet: [Int] {
        //BoardPositions containing a Card and being in "failure" state
        return board.indices.filter {
            board[$0].card != nil && board[$0].state == .failure
        }
    }
    
    func newGame() {
        //Create a new deck of 81 cards; shuffled into a random sequence
        cardDeck = CardDeck(numberOfCards: 81)
        
        //Create a board containing 24 positions upon which the game will be played
        board = [BoardPosition]()
        for _ in 1...24 {
            board.append(BoardPosition())
        }
        
        //Deal 12 cards to start the game
        dealCards(numberOfCards: 12)
    }
    
    func dealCards(numberOfCards: Int) {
        for _ in 1...numberOfCards {
            if availableBoardPosition != nil && cardDeck!.cards.count != 0 {
                let aCard = cardDeck!.draw()
                board[availableBoardPosition!].card = aCard
            }
        }
    }
    
    func selectCard(atPosition: Int ) {
        //If there are currently three selected cards
        var cardSet = selectedSet()
        if cardSet.count == 3 {
            for index in 0..<cardSet.count {
                switch board[cardSet[index]].state {
                //Then remove if they're successful
                case .success: board[cardSet[index]].card = nil
                //Else unselect them
                case .failure: board[cardSet[index]].state = .unselected
                default: break
                }
            }
        }
        
        //If the BoardPosition contains a Card then flip its Selected state
        if board[atPosition].card != nil  {
            switch board[atPosition].state {
            case .unselected: board[atPosition].state = .selected
            case .selected: board[atPosition].state = .unselected
            default: board[atPosition].state = .unselected
            }
        }
        
        //If there are now three cards then "score" them
        cardSet = selectedSet()
        if cardSet.count == 3 {
            let success = validate(for: cardSet)
            for index in 0..<cardSet.count {
                board[cardSet[index]].state = success ? .success : .failure
            }
        }
    }
    
    func validate(for theCardSet: [Int]) -> Bool {
        var success = false
        if theCardSet.count == 3 {
            for index in 0..<3 {
                
                
                
            }
        }
        return success
    }
    
} //SetApp
