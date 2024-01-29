//
//  ChangeLocationView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/22/24.
//

import SwiftUI
import CoreLocation
import _MapKit_SwiftUI

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
            ZStack {
                Map(position: $viewModel.mapPosition,
                    interactionModes: .all) {
                    if let loc = handler.location{
                        //현위치 마커
                        Annotation("", coordinate: loc.coordinate) {
                            ZStack {
                                Image(.mapIcoMarker)
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .shadow(radius: 5)
                                
                            }
                        }.mapOverlayLevel(level: .aboveLabels)
                    }
                }.onMapCameraChange { context in
                    self.centerLoc = CLLocation(latitude: context.camera.centerCoordinate.latitude,
                                                longitude: context.camera.centerCoordinate.longitude)
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("📍")
                        Spacer()
                    }
                    Spacer()
                }
            }
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
