//
//  MainMapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
struct MainMapView: View {
    @StateObject var viewModel: MainMapViewModel = .init()
    @State var draw = true
    @State var sortDistance: Bool = true
    @State var showingSheet: Bool = false
    @State var fileterSheet: Bool = false
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    var body: some View {
        ZStack {
            KakaoMapView(draw: $draw,
                         isUserTracking: $viewModel.isUserTracking,
                         userLocation: $viewModel.location,
                         clusters: $viewModel.clusters)
//            .onAppear(perform: {
//                self.draw = true
//            }).onDisappear(perform: {
//                self.draw = false
//            })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(viewModel)
                .ignoresSafeArea(edges: .top)
            VStack {
                TopBarAddress(currentAddress: $viewModel.myCurrentAddress)
                    .padding(.horizontal, 12)
                    .onAppear(){
                        viewModel.getCurrentAddress()
                    }
                HStack{
                    
                    Button{
                        
                    } label: {
                        FilterButton(buttonName: .constant("전체메뉴"))
                    }
                    .buttonStyle(RoundedRect.standard)
                    
                    Button {
                        // 거리순 - 최근 등록순
                        self.sortDistance.toggle()
                        viewModel.sortByDistance(self.sortDistance)
                    } label: {
                        FilterButton(
                            imageName: "arrow.left.arrow.right",
                            buttonName: sortDistance ?
                                .constant("거리순보기") : .constant("최근 등록순 보기")
                        )
                    }
                    .buttonStyle(RoundedRect.standard)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                Spacer()
                HStack {
                    
                    // 현 위치 버튼
                    Button {
                        viewModel.switchUserLocation()
                    } label: {
                        CurrentSpotButton()
                    }
                    
                    
                    Spacer()
                    
                    // 리스트뷰 전환 버튼
                    Button {
                        self.showingSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                            Text("리스트뷰")
                        }
                    }
                    .buttonStyle(Pill.secondary)
                    
                }
                .padding(.horizontal, 16)
                //선택한 경우
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(viewModel.MemoList) { item  in
                            
                            MemoCell(
                                isVisible: true,
                                isDark: true,
                                location: viewModel.location,
                                item: item)
                            .frame(width: UIScreen.main.bounds.size.width * 0.84)
                            .padding(.leading, 12)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            
        }.fullScreenCover(isPresented: $showingSheet) {
            MemoListView(sortDistance: $sortDistance)
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    MainMapView()
}

