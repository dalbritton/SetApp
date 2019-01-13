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
    private var numberOfBoardPositions = 24
    private var numberOfCardsInDeck = 13
    
    lazy var cards = [Card]()
    
    //A board that will contain positions upon which the game will be played
    var board = [BoardPosition]()
    
    public mutating func newGame() throws {
        try! validateStartingValues()
        //Create a new deck of cards; shuffled into a random sequence
        createCardDeck(numberOfCards: numberOfCardsInDeck)
        
        //Create a board containing BoardPositions upon which the game will be played
        board = [BoardPosition]()
        for _ in 1...numberOfBoardPositions {
            board.append(BoardPosition())
        }
        
        //Deal no more than 12 cards to start the game
        dealCards(numberOfCards: numberOfCardsInDeck < 12 ? numberOfCardsInDeck : 12)
    }
    
    struct GameCard {
        //An instance of a playing Card at a particular BoardPosition
        var card: Card
        var boardPosition: Int
    }
    
    public mutating func dealCards(numberOfCards: Int) {
        //If there is a selected "successful" set of three cards then remove them from the board
        var cardSet = selectedSet()
        if cardSet.count == 3 {
            let successful = validate(for: cardSet)
            if successful {
                for index in 0..<cardSet.count {
                    let position = cardSet[index].boardPosition
                    board[position].card = nil
                }
            }
        }
        
        //Now deal the new cards
        for _ in 1...numberOfCards {
            if let position = availableBoardPosition {
                if cards.count > 0 {
                    let card = cards.remove(at:cards.count.arc4random)
                    board[position].card = card
                    board[position].state = .unselected
                }
            }
        }
    }
    
    public mutating func selectCard(atPosition: Int ) {
        //If there are currently three selected cards
        var cardSet = selectedSet()
        if cardSet.count == 3 {
            for index in 0..<cardSet.count {
                let position = cardSet[index].boardPosition
                switch board[position].state {
                //Then remove if they're successful
                case .successful: board[position].card = nil
                //Else unselect them
                case .failed: board[position].state = .unselected
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
            let successful = validate(for: cardSet)
            for index in 0..<cardSet.count {
                let position = cardSet[index].boardPosition
                board[position].state = successful ? .successful : .failed
            }
        }
    }
    
    public func generateHints() -> [[GameCard]] {
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
    
    private var availableBoardPosition: Int? {
        //Build an array of available board positions
        var positions = [Int]()
        for position in 0..<board.count {
            //An empty (available) position contains no Card
            if board[position].card == nil {
                positions.append(position)
            }
        }
        if positions.count > 0 {
            //Build a shuffled sequence based upon the number of available board positions
            let shuffledSequence = GKShuffledDistribution(forDieWithSideCount: positions.count)
            return positions[shuffledSequence.nextInt() - 1]
        } else {
            return nil
        }
    }
    
    enum ApplicationError: Error, CustomStringConvertible {
        case rangeException(varName: String, value: Int, range: ClosedRange<Int>)
        
        var description: String {
            var text = "ApplicationError: "
            switch self {
            case .rangeException(let varName, let value, let range):
                text += "\(varName) [\(value)] must be in the range \(range)"
            default: break
            }
            return text
        }
    }
    
    private func validateStartingValues() throws {
        //The application can handle a maximum of 24 board positions
        var range = 1...24
        if !range.contains(numberOfBoardPositions) {
            throw ApplicationError.rangeException(varName: "numberOfBoardPositions", value: numberOfBoardPositions, range: range)
        }
        
        //The application can handle a maximum of 81 playing cards
        range = 1...81
        if  !range.contains(numberOfCardsInDeck) {
            throw ApplicationError.rangeException(varName: "numberOfCardsInDeck", value: numberOfCardsInDeck, range: range)
        }
    }
    //Create a deck of 81 cards; shuffled into a random sequence
    private mutating func createCardDeck(numberOfCards: Int) {
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
    
    private mutating func drawCardFromDeck() -> Card? {
        if cards.count > 0 {
            return cards.remove(at:cards.count.arc4random)
        } else {
            return nil
        }
    }
    
    private func selectedSet() -> [GameCard] {
        //GameCards in "selected" states (!= .unselected)
        var retValues = [GameCard]()
        for index in 0..<board.count {
            if board[index].card != nil && board[index].state != .unselected {
                retValues.append(GameCard(card: board[index].card!, boardPosition: index))
            }
        }
        return retValues
    }
    
    private func failedSet() -> [GameCard] {
        var retValues = [GameCard]()
        for index in 0..<board.count {
            if board[index].card != nil && board[index].state != .failed {
                retValues.append(GameCard(card: board[index].card!, boardPosition: index))
            }
        }
        return retValues
    }
    
    private func validate(for cardSet: [GameCard]) -> Bool {
        //A cardSet containing three cards and scoring 4 is a valid Set
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
    
} //SetApp
