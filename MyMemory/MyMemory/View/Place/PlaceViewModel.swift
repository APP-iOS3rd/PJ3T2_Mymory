//
//  PlaceViewModel.swift
//  MyMemory
//
//  Created by 김소혜 on 2/21/24.
//

import Foundation
import Combine

class PlaceViewModel: ObservableObject {
    
    @Published var buildingName: String = ""
    @Published var placeAddress: String = ""
    @Published var memoList: [Memo] = []
        
    @Published var location: Location = Location(latitude: 37.402101, longitude: 127.108478)
   
    let memoService = MemoService.shared
    
    init() {
       
            
    }
    
    func fetchMemoList(){
        
    }
    
//
//    private func getAddressFromCoordinates(latitude: Double, longitude: Double) {
//        
//        Task{@MainActor in
//            self.placeAddress = await GetAddress.shared.getAddressStr(location: .init(longitude: longitude, latitude: latitude))
//        }
//    }
}
