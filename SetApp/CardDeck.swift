//
//  CardDeck.swift
//  SetApp
//
//  Created by davida on 1/5/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation
import GameplayKit

class CardDeck {
    var cards = [Card]()
    
    init(numberOfCards: Int) {
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
                        print("\(index)")
                        self.cards[index].symbol = aSymbol
                        self.cards[index].pipCount = aPipCount
                        self.cards[index].color = aColor
                        self.cards[index].shading = aShading
                    }
                }
            }
        }
    }
    
     func draw() -> Card? {
        if cards.count > 0 {
            return cards.remove(at:cards.count.arc4random)
        } else {
            return nil
        }
    }
}
