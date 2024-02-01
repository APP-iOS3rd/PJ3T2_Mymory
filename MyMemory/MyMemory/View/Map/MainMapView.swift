//
//  MainMapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
import _MapKit_SwiftUI

struct MainMapView: View {
    @StateObject var mainMapViewModel: MainMapViewModel = MainMapViewModel()
    @State var draw = true
    @State var sortDistance: Bool = true
    @State var showingSheet: Bool = false
    @State var showingAlert: Bool = false
    @State var fileterSheet: Bool = false
    
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    
    let memoList: [String] = Array(1...10).map {"메모 \($0)"}
    @State var isClicked: Bool = false
    
    var body: some View {
        ZStack {
            MapView()
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
                            switch CLLocationManager.authorizationStatus() {
                            case .authorizedAlways, .authorizedWhenInUse:
                                mainMapViewModel.switchUserLocation()
                            case .notDetermined, .restricted, .denied:
                                showingAlert.toggle()
                            @unknown default:
                                mainMapViewModel.switchUserLocation()
                            }
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
                    HStack(spacing: 20) {
                        ForEach(mainMapViewModel.filterList.isEmpty ? mainMapViewModel.memoList : mainMapViewModel.filteredMemoList) { item  in
                            VStack{
                                Text("\(String(item.didLike))")
                                MemoCell(
                                    isVisible: true,
                                    isDark: true,
                                    location: $mainMapViewModel.location,
                                    memo: item)
                                .environmentObject(mainMapViewModel)
                                .onTapGesture {
                                    mainMapViewModel.memoDidSelect(memo: item)
                                }
                                .frame(width: UIScreen.main.bounds.size.width * 0.84)
                                .padding(.leading, 12)
                                .padding(.bottom, 12)
                            }
                        }
                    }
                }

                .fixedSize(horizontal: false, vertical: true)
            }
            .fullScreenCover(isPresented: $showingSheet, content: {
                MainSectionsView(sortDistance: $sortDistance)
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
        .moahAlert(isPresented: $showingAlert, moahAlert: {
            MoahAlertView(message: "현재 위치를 찾을 수 없어요. 위치서비스를 켜 주세요.", firstBtn: MoahAlertButtonView(type: .CANCEL, isPresented: $showingAlert, action: {}), secondBtn: MoahAlertButtonView(type: .SETTING, isPresented: $showingAlert, action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onAppear {
            mainMapViewModel.refreshMemos()
        }
    }
}

#Preview {
    MainMapView()
}

