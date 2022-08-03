//
//  ListRowModifier.swift
//  PickTwo
//
//  Created by Brett Walton on 8/3/22.
//

import Foundation
import SwiftUI

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            content
            Divider()
        }.offset(x: 10)
    }
}
