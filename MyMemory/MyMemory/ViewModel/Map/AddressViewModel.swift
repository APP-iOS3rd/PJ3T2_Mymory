//
//  AddressViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import Foundation
import Combine

class AddressViewModel: ObservableObject{
    @Published var addressList: [AddressData] = []
    
    init() {
        fetchModel()
        
    }
    
    func fetchModel(){
        self.addressList = [
            AddressData(name: "사당역 4번출구", address: "서울시 동작구 사당동"),
            AddressData(name: "사당역 4번출구", address: "서울시 동작구 사당동"),
            AddressData(name: "사당역 4번출구", address: "서울시 동작구 사당동"),
            AddressData(name: "사당역 4번출구", address: "서울시 동작구 사당동"),
            AddressData(name: "사당역 4번출구", address: "서울시 동작구 사당동"),
        ]
    }
    
}
