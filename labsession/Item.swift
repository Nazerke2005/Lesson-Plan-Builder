//
//  Item.swift
//  labsession
//
//  Created by Nazerke Turganbek on 05.12.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
