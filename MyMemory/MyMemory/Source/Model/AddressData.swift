//
//  AddressData.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import Foundation

struct AddressData: Identifiable {
      var id: String { self.name }
      var name: String
      var address: String
}

