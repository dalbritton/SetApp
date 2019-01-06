//
//  BoardPosition.swift
//  SetApp
//
//  Created by davida on 1/2/19.
//  Copyright © 2019 davida. All rights reserved.
//

import Foundation

class BoardPosition {
    var card: Card?
    var state = State.unselected

    enum State {
        case unselected, selected, success, failure
    }
}
