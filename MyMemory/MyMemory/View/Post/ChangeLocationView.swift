//
//  ChangeLocationView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/22/24.
//

import SwiftUI
import CoreLocation
struct ChangeLocationView: View {
    @State var handler = LocationsHandler.shared
    @State var centerLoc: CLLocation? = nil {
        didSet {
            if let loc = centerLoc {
                viewModel.getAddress(with: .init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
            }
        }
    }
    @EnvironmentObject var viewModel: PostViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            KakaoMapSimple(draw: .constant(true),
                           userLocation: $handler.location,
                           userDirection: $handler.heading,
                           centerLocation: $centerLoc)
            VStack(alignment: .leading) {
                Text("바로 여기에 메모를 남길거에요!")
                    .font(.bold22)
                    .padding(.top, 40)
                    .padding(.leading, 17)
                    .padding(.bottom, 20)
                
                RoundedRectangle(cornerRadius: 15)
                    .padding(.horizontal, 17)
                    .overlay(
                        Text("\(viewModel.tempAddressText)")
                            .foregroundStyle(Color.darkGray)
                            .font(.bold16)
                    )
                    .foregroundStyle(Color.lightGrayBackground)
                    .frame(height: 50)
                    .padding(.bottom,20)
                Button(action: {
                    if let _ = centerLoc {
                        viewModel.setAddress()
                    }
                    dismiss()
                }, label: {
                    HStack {
                        Spacer()
                        Text("이 위치로 하기")
                            .padding(.vertical, 5)
                        Spacer()
                    }
                }).padding(.horizontal, 17)
                    .buttonStyle(RoundedRect.active)
                    
            }.frame(maxWidth: .infinity)
            .cornerRadius(16, corners: [.topLeft,.topRight])
            .background(Color.white)
        }
    }
}

#Preview {
    ChangeLocationView()
}
