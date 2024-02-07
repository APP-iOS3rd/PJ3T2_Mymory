//
//  FontViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 2/6/24.
//

import Foundation
import SwiftUI
import Combine

struct FontFamily: Identifiable, Hashable {
    var id: Int
    var name: String
    var font: FontType
}


final class FontViewModel: ObservableObject {
    @Published var fontList: [FontFamily] = []
    
}
