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
    private(set) var cards = [Card]()
    
    init(cardCount: Int) {
        //Get a random list of cardNumbers to use as we create new Cards (1...cardCount)
        let shuffledSequence = GKShuffledDistribution(forDieWithSideCount: cardCount)
        for symbol in Card.Symbol.all {
            for pipCount in Card.PipCount.all {
                for color in Card.Color.all {
                    for shading in Card.Shading.all {
                        cards.append(Card(
                                cardIdentifier: shuffledSequence.nextInt() - 1
                                , symbol: symbol
                                , pipCount: pipCount
                                , color: color
                                , shading: shading
                            )
                        )
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
