//
//  CertificationView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/16/24.
//

import SwiftUI
import _MapKit_SwiftUI

struct CertificationView: View {
    @State var mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
    @Binding var memo: Memo
    @State var draw:Bool = true
    @StateObject private var viewModel: CertificationViewModel = CertificationViewModel()
    
    var body: some View {
        ZStack {
            
            Color.bgColor 
            VStack {
                VStack {
                    VStack {
                        Text("장소 근처")
                            .font(.bold24)
                        +
                        Text("에서")
                            .font(.regular24)
                        
                        Text("메모를 확인할 수 있어요!")
                            .font(.regular24)
                    }
                    .frame(alignment: .center)
                    .foregroundStyle(Color.textColor)
                    .padding(.top, 20)
                }
                
                Spacer()
                Map(position: $mapPosition,
                    interactionModes: .all) {
                    if let loc = viewModel.location{
                        Annotation("", coordinate: loc.coordinate) {
                            ZStack {
                                Image(.mapIcoMarker)
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .shadow(radius: 5)

                            }
                        }.mapOverlayLevel(level: .aboveLabels)
                        
                    }
                    Annotation("", coordinate: .init(latitude: memo.location.latitude, longitude: memo.location.longitude)) {
                        Image(.makerMineSelected)
                    }
                }
                    .clipShape(.rect(cornerRadius: 10))
                    .frame(height: UIScreen.main.bounds.size.height * 0.55)
                    .padding()
//                CertificationMap(memo: $memo, draw: $viewModel.draw, isUserTracking: $viewModel.isUserTracking, userLocation: $viewModel.location, userDirection: $viewModel.direction)
//                        .onAppear {
//                            DispatchQueue.main.async {
//                                self.draw = true
//                            }
//                        }
//                        .onDisappear {
//                            self.draw = false
//                        }
//                        .environmentObject(viewModel)

                    
                    Spacer()
                    
                    ProgressBarView(memo: $memo, userLocation: $viewModel.location)
                        .environmentObject(viewModel)
                        .ignoresSafeArea()
                    
            }
            .edgesIgnoringSafeArea(.bottom)
            
        }
        .customNavigationBar(
            centerView: {
                Text(" ")
            },
            leftView: {
                EmptyView()
            },
            rightView: {
                CloseButton()
            },
            backgroundColor: .bgColor
        )
    }
}
