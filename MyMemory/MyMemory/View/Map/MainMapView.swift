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
    @State var draw = true
    var body: some View {
        ZStack {
            KakaoMapView(draw: $draw,
                         isUserTracking: $viewModel.isUserTracking,
                         userLocation: $viewModel.location,
                         clusters: $viewModel.clusters)
                .onAppear(perform: {
                            self.draw = true
                        }).onDisappear(perform: {
                            self.draw = false
                        }).frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(viewModel)
                .ignoresSafeArea(edges: .top)
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: $viewModel.searchTxt)
                            .font(.regular16)
                            .foregroundStyle(Color.primary.opacity(0.6))
                            
                        if !viewModel.searchTxt.isEmpty {
                            Button(action: {
                                self.viewModel.searchTxt = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                            }
                        } else {
                            EmptyView()
                        }
                    }            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(Color(red: 0.46, green: 0.46, blue: 0.5).opacity(0.12))
                        .cornerRadius(10.0)
                }
                .padding(.horizontal)
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
                //선택한 경우
                if let contents = viewModel.selectedCluster {
                    ClusterSelectionView(contents: viewModel.MemoList,selectedItemID: $viewModel.selectedMemoId)
                        .environmentObject(viewModel)
                    
                }
            }
        }
    }
}

#Preview {
    MainMapView()
}

