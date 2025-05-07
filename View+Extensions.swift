//
//  View+Extensions.swift
//  FundingForce_01
//
//  Created by Imad Labbadi on 05.05.25.
//

import SwiftUI

extension View {
    // Runde Kartenansicht mit Schatten
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color(.windowBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
