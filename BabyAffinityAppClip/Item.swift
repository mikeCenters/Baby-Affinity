//
//  Item.swift
//  BabyAffinityAppClip
//
//  Created by Mike Centers on 9/18/24.
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
