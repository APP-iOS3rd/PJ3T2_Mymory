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
    @State var presentLoginView: Bool = false
    @State var fileterSheet: Bool = false
    @State private var presentLoginAlert = false
    @State var currentAppearingMemo: Memo? = nil {
        didSet {
            if let memo = currentAppearingMemo {
                mainMapViewModel.memoDidSelect(memo: memo)
            }
        }
    }
    @Environment(\.scenePhase) var phase
    
    @ObservedObject var noti = PushNotification.shared
//    @ObservedObject var otherUserViewModel: OtherUserViewModel = .init()
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    private var operationQueue = OperationQueue()
    
    let memoList: [String] = Array(1...10).map {"메모 \($0)"}
    @State var isClicked: Bool = false
    
    var body: some View {
        ZStack {
            MapView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(mainMapViewModel)
                .ignoresSafeArea(edges: .top)
                .onChange(of: phase) { oldValue, newValue in
                    switch newValue {
                    case .active:
                        mainMapViewModel.refreshMemos()
                    @unknown default:
                        break
                        
                    }
                }
            VStack {
                TopBarAddress(currentAddress: $mainMapViewModel.myCurrentAddress, mainMapViewModel: mainMapViewModel)
                    .padding(.horizontal, 12)
                    .onAppear(){
                        //10초에 한번
                        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { t in
                            // 50미터 밖일 때
                            if mainMapViewModel.dist > 50 {
                                mainMapViewModel.getCurrentAddress()
                            }
                        }
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
                ScrollViewReader { proxy in
                    //선택한 경우
                    ScrollView(.horizontal) {
                        HStack(spacing: 20) {
                            ForEach(mainMapViewModel.filterList.isEmpty ? Array(zip(mainMapViewModel.memoList.indices, $mainMapViewModel.memoList)) : Array(zip(mainMapViewModel.filteredMemoList.indices, $mainMapViewModel.filteredMemoList)), id: \.0) { index, item  in
                                VStack{
                                    //                                Text("\(String(item.didLike))")
                                    MemoCell(                                        
                                        location: $mainMapViewModel.location,
                                        selectedMemoIndex: index,
                                        memo: item,
                                        memos: mainMapViewModel.filterList.isEmpty ? $mainMapViewModel.memoList : $mainMapViewModel.filteredMemoList
                                    ) { res in
                                        if res {
                                            presentLoginAlert.toggle()
                                        }
                                    }
                                    .id(item.id)
                                    .environmentObject(mainMapViewModel)
                                    .onTapGesture {
                                        mainMapViewModel.memoDidSelect(memo: item.wrappedValue)
                                    }
                                    .frame(width: UIScreen.main.bounds.size.width * 0.84)
                                    .padding(.leading, 12)
                                    .padding(.bottom, 12)
                                    .background {
                                        GeometryReader { geometry in
                                            Color.clear
                                                .onAppear {
                                                    let minx = geometry.frame(in: .global).minX
                                                    let scrollViewWidth = geometry.frame(in: .global).width
                                                    let contentsWidth = geometry.frame(in: .local).width
                                                    var idx = index
                                                    let oldid = mainMapViewModel.selectedMemoId
                                                    let newid = item.id
                                                }
                                                .onChange(of: geometry.frame(in: .global).minX) { old, minX in
                                                    if minX < 180 && minX > -10 {
                                                        operationQueue.cancelAllOperations()
                                                        operationQueue.addOperation{
                                                            DispatchQueue.main.async{
                                                                if item.id != currentAppearingMemo?.id {
                                                                    currentAppearingMemo = item.wrappedValue
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                }
                            }
                            Spacer().frame(width: 12)
                        }
                        
                        .scrollTargetLayout()
                    }
                    .onChange(of: mainMapViewModel.selectedMemoId) { old, new in
                        proxy.scrollTo(new, anchor: .center)
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .fullScreenCover(isPresented: $showingSheet, content: {
               ListView(sortDistance: $sortDistance
//                                 ,otherUserViewModel: otherUserViewModel
                ) { logout in
                    if logout {
                        self.presentLoginView = true
                    }
                }
                .environmentObject(mainMapViewModel)
            })
            .moahAlert(isPresented: $presentLoginAlert) {
                        MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                                      firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
                        }),
                                      secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                            self.presentLoginView = true
                        })
                        )
                    }
            .sheet(isPresented: $fileterSheet, content: {
                FilterListView(filteredList: $mainMapViewModel.filterList)
                    .background(Color.bgColor)
                    .presentationDetents([.medium])
            })
        }.overlay(content: {
            if mainMapViewModel.isLoading {
                LoadingView()
            }
        })
        //.toolbar(.hidden)
        .navigationDestination(item:$noti.memo,
                               destination: {memo in
            
            MemoDetailView(memos: .constant([memo]), selectedMemoIndex: 0)
            
        })
        .moahAlert(isPresented: $showingAlert, moahAlert: {
            MoahAlertView(message: "현재 위치를 찾을 수 없어요. 위치서비스를 켜 주세요.", firstBtn: MoahAlertButtonView(type: .CANCEL, isPresented: $showingAlert, action: {}), secondBtn: MoahAlertButtonView(type: .SETTING, isPresented: $showingAlert, action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onAppear {
            mainMapViewModel.refreshMemos()
            
        }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView()
        }
        
    }
}

#Preview {
    MainMapView()
}

