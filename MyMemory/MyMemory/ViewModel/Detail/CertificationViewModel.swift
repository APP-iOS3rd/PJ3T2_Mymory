//
//  CertificationViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/19/24.
//

import SwiftUI
import CoreLocation
import Combine
import MapKit
import KakaoMapsSDK
final class CertificationViewModel: NSObject, ObservableObject {
    

    //view로 전달할 값 모음
    @Published var myCurrentAddress: String? = nil
    @Published var direction: Double = 0
    @Published var draw: Bool = true
    @Published var isUserTracking: Bool = true
    @Published var selectedAddress: String? = nil
    
    override init() {
        super.init()

        getCurrentAddress()
    }
}



//MARK: - Location
extension CertificationViewModel {
    
    //MARK: - 주소 얻어오는 함수
    //특정 selected 위치 주소값
    private func getAddressFromCoordinates(latitude: Double, longitude: Double) {
        Task{@MainActor in
            self.selectedAddress = await GetAddress.shared.getAddressStr(location: .init(longitude: longitude, latitude: latitude))
        }
    }
    //user location주소값
    func getCurrentAddress() {
        guard let loc = LocationsHandler.shared.location else { return }
        let point = MapPoint(longitude: loc.coordinate.longitude, latitude: loc.coordinate.latitude)
        Task{@MainActor in
            self.myCurrentAddress = await GetAddress.shared.getAddressStr(location: point)
        }
    }
}
