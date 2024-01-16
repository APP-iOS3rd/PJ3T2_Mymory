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
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
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
                TopBarAddress()
                    .padding(.horizontal, 12)
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
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(viewModel.MemoList) { item  in
                            
                            MemoCell(isVisible: true, isDark: true)
                                .frame(width: UIScreen.main.bounds.size.width * 0.84)
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    MainMapView()
}

