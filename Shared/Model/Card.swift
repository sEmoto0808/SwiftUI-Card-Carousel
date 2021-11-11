//
//  Card.swift
//  swiftui-card-carousel-sample (iOS)
//
//  Created by Sho Emoto on 2021/11/11.
//

import SwiftUI

/// Sample Card Model and Card Data
struct Card: Identifiable {
    let id = UUID().uuidString
    let cardColor: Color
    let date: String
    let title: String
}
