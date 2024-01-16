//
//  MemoMapView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI
import Combine
import MapKit
import CoreLocation

struct MemoMapView: View {
    @State var draw = true

    @ObservedObject var viewModel: MainMapViewModel = .init()
    // LazyHGrid GridItem
    // 화면 그리드 형식으로 채워줌 임시변수
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    
    let memoList: [String] = Array(1...10).map {"메모 \($0)"}
    @State var sortDistance: Bool = true
    @State var showingSheet: Bool = false
    
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
                
                HStack{
                    
                    Button{
                        
                    } label: {
                        FilterButton(buttonName: .constant("전체메뉴"))
                    }
                    .buttonStyle(RoundedRect.standard)
                    
                    Button {
                        // 거리순 - 최근 등록순
                        self.sortDistance.toggle()
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
//                if let contents = viewModel.selectedCluster {
//                    ClusterSelectionView(contents: contents)
//                        .environmentObject(viewModel)
//                }
                
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(memoList, id: \.self) { item  in
                            
                            MemoCell(isVisible: true, isDark: true)
                                .frame(width: UIScreen.main.bounds.size.width * 0.84)
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .fullScreenCover(isPresented: $showingSheet) {
                MemoListView()
            }
        }
    }
   
}

#Preview {
    MemoMapView()
}
