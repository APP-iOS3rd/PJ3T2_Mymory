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
    @State var distanceAlert: Bool = false
    @State var centerLoc: CLLocation? = nil {
        didSet {
            if let loc = centerLoc {
                
                viewModel.getAddress(with: .init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
                
                if let currentloc = handler.location {
                    if loc.distance(from: currentloc) > MemoService.shared.readableArea {
                        distanceAlert.toggle()

                    }
                }
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
                        MapCircle(center: loc.coordinate, radius: MemoService.shared.readableArea)
                            .foregroundStyle(Color(red: 0.98, green: 0.15, blue: 0.15).opacity(0.1))
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
                        VStack {
                            if let buildingName = viewModel.memoAddressBuildingName {
                                Text("\(buildingName)")
                                    .foregroundStyle(Color.darkGray)
                                    .font(.bold16)
                                Text("\(viewModel.tempAddressText)")
                                    .foregroundStyle(Color.deepGray)
                                    .font(.regular12)
                            } else {
                                Text("\(viewModel.tempAddressText)")
                                    .foregroundStyle(Color.darkGray)
                                    .font(.bold16)
                            }
                        }
                    )
                    .foregroundStyle(Color.lightGrayBackground)
                    .frame(height: 50)
                    .padding(.bottom,20)
                Button(action: {
                    if let _ = centerLoc {
                        viewModel.setAddress()
                        if let loc = centerLoc {
                            viewModel.setLocation(locatioin: loc)
                        }
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
            .background(Color.bgColor)
        }
        .customNavigationBar(
            centerView: {
                Text("")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: .bgColor
        ).moahAlert(isPresented: $distanceAlert) {
            MoahAlertView(title: "너무 먼 곳은 안돼요!",message: "\(Int(MemoService.shared.readableArea))M 이내에만 등록 가능합니다.", firstBtn: .init(type: .CONFIRM, isPresented: $distanceAlert, action: {
                guard let loc = handler.location else {return}
                viewModel.mapPosition = MapCameraPosition.camera(.init(centerCoordinate: .init(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude), distance: 500))
            }))
        }
    }
}

#Preview {
    ChangeLocationView()
}
