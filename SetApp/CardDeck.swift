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
    private(set) var cards: [Card]
    
    init(numberOfCards: Int) {
        cards = Array(repeating: Card(), count: numberOfCards)
        //Get a list of random sequences to use for shuffling
        let shuffledSequence = GKShuffledDistribution(forDieWithSideCount: numberOfCards)
        for symbol in Card.Symbol.all {
            for pipCount in Card.PipCount.all {
                for color in Card.Color.all {
                    for shading in Card.Shading.all {
                        let index = shuffledSequence.nextInt() - 1
                        cards[index].symbol = symbol
                        cards[index].pipCount = pipCount
                        cards[index].color = color
                        cards[index].shading = shading
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
