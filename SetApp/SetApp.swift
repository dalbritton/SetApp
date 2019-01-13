//
//  SetApp.swift
//  SetApp
//
//  Created by davida on 1/1/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation
import GameplayKit

struct SetApp {
    lazy var cards = [Card]()
    
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
    
    mutating func newGame() {
        //Create a new deck of 81 cards; shuffled into a random sequence
        createCardDeck(numberOfCards: 13)
        
        //Create a board containing 24 positions upon which the game will be played
        board = [BoardPosition]()
        for _ in 1...24 {
            board.append(BoardPosition())
        }
        
        //Deal 12 cards to start the game
        dealCards(numberOfCards: 12)
    }
    
    struct GameCard {
        //An instance of a playing Card at a particular BoardPosition
        var card: Card
        var boardPosition: Int
    }

    //A deck of 81 cards; shuffled into a random sequence
    mutating func createCardDeck(numberOfCards: Int) {
        for _ in 0..<numberOfCards {
            self.cards.append(Card())
        }
        //Get a list of random sequences to use for shuffling
        let shuffledSequence = GKShuffledDistribution(forDieWithSideCount: numberOfCards)
        for aSymbol in Card.Symbol.all {
            for aPipCount in Card.PipCount.all {
                for aColor in Card.Color.all {
                    for aShading in Card.Shading.all {
                        let index = shuffledSequence.nextInt() - 1
                        self.cards[index].symbol = aSymbol
                        self.cards[index].pipCount = aPipCount
                        self.cards[index].color = aColor
                        self.cards[index].shading = aShading
                    }
                }
            }
        }
    }
    
    mutating func drawCardFromDeck() -> Card? {
        if cards.count > 0 {
            return cards.remove(at:cards.count.arc4random)
        } else {
            return nil
        }
    }
    
    func selectedSet() -> [GameCard] {
        //GameCards in "selected" states (!= .unselected)
        var retValues = [GameCard]()
        for index in 0..<24 {
            if board[index].card != nil && board[index].state != .unselected {
                retValues.append(GameCard(card: board[index].card!, boardPosition: index))
            }
        }
        return retValues
    }
    
    func failureSet() -> [GameCard] {
        var retValues = [GameCard]()
        for index in 0..<24 {
            if board[index].card != nil && board[index].state != .failure {
                retValues.append(GameCard(card: board[index].card!, boardPosition: index))
            }
        }
        return retValues
    }
    
    mutating func dealCards(numberOfCards: Int) {
        //If there is a currently selected "success" set of three cards then remove them from the board
        var cardSet = selectedSet()
        if cardSet.count == 3 {
            let success = validate(for: cardSet)
            if success {
                for index in 0..<cardSet.count {
                    let aPosition = cardSet[index].boardPosition
                    board[aPosition].card = nil
                }
            }
        }
        
        //Now deal the new cards
        for _ in 1...numberOfCards {
            if availableBoardPosition != nil && cards.count != 0 {
                let availablePosition = availableBoardPosition!
                if let card = drawCardFromDeck() {
                    board[availablePosition].card = card
                    board[availablePosition].state = .unselected
                }
            }
        }
    }
    
    mutating func selectCard(atPosition: Int ) {
        //If there are currently three selected cards
        var cardSet = selectedSet()
        if cardSet.count == 3 {
            for index in 0..<cardSet.count {
                let aPosition = cardSet[index].boardPosition
                switch board[aPosition].state {
                //Then remove if they're successful
                case .success: board[aPosition].card = nil
                //Else unselect them
                case .failure: board[aPosition].state = .unselected
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
        
        //If there are now three cards "selected" then "validate" them
        cardSet = selectedSet()
        if cardSet.count == 3 {
            let success = validate(for: cardSet)
            for index in 0..<cardSet.count {
                let aPosition = cardSet[index].boardPosition
                board[aPosition].state = success ? .success : .failure
            }
        }
    }
    
    func validate(for cardSet: [GameCard]) -> Bool {
        var score = 0
        if cardSet.count == 3 {
            let card1 = cardSet[0].card
            let card2 = cardSet[1].card
            let card3 = cardSet[2].card
            
            //They all have the same number or have three different numbers
            let pips: Set = [ card1.pipCount, card2.pipCount ]
            if (card1.pipCount == card2.pipCount && card2.pipCount == card3.pipCount)
                || (card1.pipCount != card2.pipCount && !pips.contains(card3.pipCount) )
            { score += 1
            }
            
            //They all have the same symbol or have three different symbols
            let symbols: Set = [ card1.symbol, card2.symbol ]
            if (card1.symbol == card2.symbol && card2.symbol == card3.symbol)
                || (card1.symbol != card2.symbol && !symbols.contains(card3.symbol) )
            { score += 1
            }
            
            //They all have the same shading or have three different shadings
            let shadings: Set = [ card1.shading, card2.shading ]
            if (card1.shading == card2.shading && card2.shading == card3.shading)
                || (card1.shading != card2.shading && !shadings.contains(card3.shading) )
            { score += 1
            }
            
            //They all have the same color or have three different colors
            let colors: Set = [ card1.color, card2.color ]
            if (card1.color == card2.color && card2.color == card3.color)
                || (card1.color != card2.color && !colors.contains(card3.color) )
            { score += 1
            }
        }
        
        return score == 4
    }
    
    func generateHints() -> [[GameCard]] {
        var allCards = [GameCard]()
        
        //Build a Set of all GameCards
        for index in 0..<board.count {
            if board[index].card != nil {
                allCards.append(GameCard(card: board[index].card!, boardPosition: index))
            }
        }
        var hints = [[GameCard]]()
        //No chance of a hint of there are fewer than 3 cards
        if allCards.count < 3 { return hints }
        
        var counter = 0
        var aSelection = [GameCard]()
        for card1Index in 0..<allCards.count-2 {
            for card2Index in card1Index+1..<allCards.count-1 {
                for card3Index in card2Index+1..<allCards.count {
                    counter += 1
                    aSelection.removeAll()
                    aSelection.append(allCards[card1Index])
                    aSelection.append(allCards[card2Index])
                    aSelection.append(allCards[card3Index])
                    if validate(for: aSelection) {
                        hints.append(aSelection)
                    }
                }
            }
        }
        return hints
    }
} //SetApp
