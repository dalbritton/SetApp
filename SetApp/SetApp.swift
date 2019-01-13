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
    private var numberOfCardsInDeck = 81
    private var hints = [(Int, Int, Int)]()
    private var allPositionsHavingCards: [Int]? {
        var positions = [Int]()
        for index in board.indices {
            if board[index].card != nil {
                positions.append(index)
            }
        }
        return positions.count > 0 ? positions : nil
    }
    
    public lazy var cards = [Card]()
    
    //A board that will contain positions upon which the game will be played
    public var board = [BoardPosition]()
    
    public var status = ""
    public var hintButtonLabel = ""
    
    public mutating func newGame() {
        try! validateStartingValues()
        
        //Create a new deck of cards; shuffled into a random sequence
        createCardDeck(numberOfCards: numberOfCardsInDeck)
        
        //Create a board containing BoardPositions upon which the game will be played
        board = [BoardPosition]()
        for _ in 1...numberOfBoardPositions {
            board.append(BoardPosition())
        }
        
        //Deal no more than 12 cards to start the game
        dealCards(numberOfCards: numberOfCardsInDeck < 12 ? numberOfCardsInDeck : 12, withBorder: false)
        
        clearHints()
    }
    
    public mutating func dealCards(numberOfCards: Int, withBorder: Bool) {
        clearBorders(withState: BoardPosition.State.dealt)
        
        //If there is a selected "successful" set of three cards then remove them from the board
        if let positions = selectedPositions() {
            if positions.count == 3 {
                let successful = validate(for: positions)
                if successful {
                    for index in positions.indices {
                        board[positions[index]].card = nil
                    }
                }
            }
        }
        
        //Now deal the new cards
        var count = 0
        for _ in 1...numberOfCards {
            if let position = availableBoardPosition {
                if cards.count > 0 {
                    let card = cards.remove(at:cards.count.arc4random)
                    board[position].card = card
                    board[position].state = withBorder ? .dealt : .unselected
                    count += 1
                }
            }
        }
        clearHints()
        status = "\(count) new cards have been dealt"
    }
    
    private mutating func clearBorders(withState: BoardPosition.State) {
        //Clear all the borders having "withState"
        if let positions = allPositionsHavingCards {
            for index in positions.indices {
                if board[positions[index]].state == withState {
                    board[positions[index]].state = .unselected
                }
            }
        }
    }
    
    public mutating func selectCard(atPosition: Int ) {
        clearBorders(withState: BoardPosition.State.dealt)
        if hints.count == 0 { status = "" }
        
        //If there are currently three selected card positions
        var successfulSet = false
        if let positions = selectedPositions() {
            if positions.count == 3 {
                for index in positions.indices {
                    switch board[positions[index]].state {
                    //Then remove if they're successful
                    case .successful:
                        board[positions[index]].card = nil
                        successfulSet = true
                    //Else unselect them
                    case .failed:
                        board[positions[index]].state = .unselected
                    default: break
                    }
                }
                if successfulSet {
                    dealCards(numberOfCards: 3, withBorder: true)
                    if positions.contains(atPosition) { return }
                }
            }
        }
        
        //If the selected BoardPosition contains a Card then flip its Selected state
        if board[atPosition].card != nil  {
            switch board[atPosition].state {
            case .unselected, .dealt:
                board[atPosition].state = .selected
            case .selected:
                board[atPosition].state = .unselected
            default:
                board[atPosition].state = .unselected
            }
        }
        
        //If there are now three cards "selected" then "validate" them
        if let positions = selectedPositions() {
            if positions.count == 3 {
                let successful = validate(for: positions)
                for index in positions.indices {
                    board[positions[index]].state = successful ? .successful : .failed
                }
            }
        }
        
    }
    
    private mutating func clearHints() {
        hints.removeAll()
        hintButtonLabel = "Hints"
        status = ""
    }
    
    public mutating func generateHints() {
        if hints.count > 0 {
            clearHints()
            return
        }
        
        //Build a Set of all positions containing cards
        var positions = [Int]()
        for index in board.indices {
            if board[index].card != nil {
                positions.append(index)
            }
        }
        
        //No chance of a hint if there are fewer than 3 cards
        if positions.count < 3 {
            hints.removeAll()
        } else {
            var counter = 0
            var selectionPositions = [Int]()
            for card1Position in 0..<positions.count-2 {
                for card2Position in card1Position+1..<positions.count-1 {
                    for card3Position in card2Position+1..<positions.count {
                        counter += 1
                        selectionPositions.removeAll()
                        selectionPositions.append(positions[card1Position])
                        selectionPositions.append(positions[card2Position])
                        selectionPositions.append(positions[card3Position])
                        if validate(for: selectionPositions) {
                            hints.append((selectionPositions[0], selectionPositions[1], selectionPositions[2]))
                        }
                    }
                }
            }
        }
        
        if hints.count == 0 {
            status = "No Sets among the cards shown"
            hintButtonLabel = "Hints"
        } else {
            var hintString = ""
            for index in hints.indices {
                let selection: (card1:Int, card2: Int , card3:Int ) = hints[index]
                hintString += "\(selection.card1+1),\(selection.card2+1),\(selection.card3+1)   "
            }
            status = hintString
            hintButtonLabel = "Hints (\(hints.count))"
        }
    }
    
    public var availableBoardPosition: Int? {
        //Build an array of available board positions
        var positions = [Int]()
        for index in board.indices {
            //An empty (available) position contains no Card or contains a .successfully matched card
            if board[index].card == nil || board[index].state == .successful {
                positions.append(index)
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
    
    public enum ApplicationError: Error, CustomStringConvertible {
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
        cards.removeAll()
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
    
    private func selectedPositions() -> [Int]? {
        //Return an array of BoardPosition indices having "selected" states
        var positions = [Int]()
        for index in board.indices {
            if board[index].card != nil {
                switch board[index].state {
                case .selected, .failed, .dealt, .successful:
                    positions.append(index)
                default: break
                }
            }
        }
        return positions.count > 0 ? positions : nil
    }
    
    private func failedPositions() -> [Int]? {
        //Return an array of all BoardPosition indices having "failed" states
        var positions = [Int]()
        for index in board.indices {
            if board[index].card != nil && board[index].state == .failed {
                positions.append(index)
            }
        }
        return positions.count > 0 ? positions : nil
    }
    
    private func validate(for positions: [Int]) -> Bool {
        //A cardSet containing three cards and scoring 4 is a valid Set
        var score = 0
        if positions.count == 3 {
            let card1 = board[positions[0]].card!
            let card2 = board[positions[1]].card!
            let card3 = board[positions[2]].card!
            
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
