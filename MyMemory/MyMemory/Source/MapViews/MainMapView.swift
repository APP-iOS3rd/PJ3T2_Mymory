//
//  MainMapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
import MapKit
struct MainMapView: View {
    @ObservedObject var viewModel: MainMapViewModel = .init()
    var body: some View {
        ZStack {
            MapViewRepresentable(region: $viewModel.region, annotations: $viewModel.annotations, isUserTracking: $viewModel.isUserTracking
            ).ignoresSafeArea()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.switchUserLocation()
                    },
                           label: {
                        Text("내 위치 보기")
                            .foregroundStyle(viewModel.isUserTracking ? Color.blue : Color.black)
                            .font(.bold14)
                            .padding(5)
                    })
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                }
            }
        }
    }
}

#Preview {
    MainMapView()
}
