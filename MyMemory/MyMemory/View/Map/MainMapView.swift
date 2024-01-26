//
//  MainMapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
struct MainMapView: View {
    @StateObject var mainMapViewModel: MainMapViewModel = MainMapViewModel()
    @State var draw = true
    @State var sortDistance: Bool = true
    @State var showingSheet: Bool = false
    @State var fileterSheet: Bool = false
    
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    
    
    let memoList: [String] = Array(1...10).map {"메모 \($0)"}
    @State var isClicked: Bool = false
    
    var body: some View {
        ZStack {
            KakaoMapView(draw: $draw,
                         isUserTracking: $mainMapViewModel.isUserTracking,
                         userLocation: $mainMapViewModel.location, userDirection: $mainMapViewModel.direction,
                         clusters: $mainMapViewModel.clusters,
                         selectedID: $mainMapViewModel.selectedMemoId)
            .onAppear{
                DispatchQueue.main.async {
                    self.draw = true
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(mainMapViewModel)
            .ignoresSafeArea(edges: .top)
            VStack {
                TopBarAddress(currentAddress: $mainMapViewModel.myCurrentAddress, mainMapViewModel: mainMapViewModel)
                    .padding(.horizontal, 12)
                    .onAppear(){
                        mainMapViewModel.getCurrentAddress()
                    }
                HStack{
                    
                    Button{
                        self.fileterSheet.toggle()
                    } label: {
                        FilterButton(buttonName: .constant(mainMapViewModel.filterList.isEmpty ? "전체메뉴" : mainMapViewModel.filterList.combinedWithComma))
                    }
                    .buttonStyle(mainMapViewModel.filterList.isEmpty ? RoundedRect.standard : RoundedRect.selected)
                    
                    Button {
                        // 거리순 - 최근 등록순
                        self.sortDistance.toggle()
                        mainMapViewModel.sortByDistance(self.sortDistance)
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
                if mainMapViewModel.isFarEnough {
                    Button(action: {
                        mainMapViewModel.fetchMemos()
                        mainMapViewModel.firstLocation = mainMapViewModel.location
                    },
                           label: {
                        Text("현재 지도에서 메모 재검색")
                    }).buttonStyle(Pill.standard)
                        .padding(.top,10)
                }
                Spacer()
                HStack {
                    
                    // 현 위치 버튼
                    Button {
                        mainMapViewModel.switchUserLocation()
                    } label: {
                        CurrentSpotButton()
                    }
                    
                    
                    Spacer()
                    
                    // 리스트뷰 전환 버튼
                    Button {
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                            Text("리스트뷰")
                        }
                        .onTapGesture {
                            self.showingSheet = true
                        }
                    }
                    .buttonStyle(Pill.secondary)
                    
                }
                .padding(.horizontal, 16)
                
                //선택한 경우
                ScrollView(.horizontal) {
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(mainMapViewModel.filterList.isEmpty ? mainMapViewModel.memoList : mainMapViewModel.filteredMemoList) { item  in
                            
                            MemoCell(
                                isVisible: true,
                                isDark: true, location: $mainMapViewModel.location,
                                memo: item)
                                .environmentObject(mainMapViewModel)
                            .onTapGesture {
                                mainMapViewModel.selectedMemoId = item.id
                            }
                            .frame(width: UIScreen.main.bounds.size.width * 0.84)
                            .padding(.leading, 12)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .fullScreenCover(isPresented: $showingSheet, content: {
                MemoListView(sortDistance: $sortDistance)
                    .environmentObject(mainMapViewModel)
            })
            
            .sheet(isPresented: $fileterSheet, content: {
                FileterListView(filteredList: $mainMapViewModel.filterList)
                    .background(Color.lightGrayBackground)
                    .presentationDetents([.medium])
            })
        }.overlay(content: {
            if mainMapViewModel.isLoading {
                LoadingView()
            }
        })
        .onAppear {
            mainMapViewModel.refreshMemos()
        }
    }
}

#Preview {
    MainMapView()
}

