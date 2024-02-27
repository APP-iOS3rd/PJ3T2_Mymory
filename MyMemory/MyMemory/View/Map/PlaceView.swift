//
//  PlaceView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/21/24.
//

import SwiftUI
import MapKit
 
struct PlaceView: View {
    @State var location: Location
    @State var buildingName: String
    @State var address: String
    @State var mapPosition = MapCameraPosition.userLocation(fallback: .automatic)
    @State var presentLoginAlert: Bool = false
    @State var presentLoginView: Bool = false
    @StateObject var locationHandler = LocationsHandler.shared
    @StateObject var viewModel: PlaceViewModel = .init()
    @State var selectedUser: Profile? = nil
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            Map(initialPosition: .region(MKCoordinateRegion(center: coordinate, span: (MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))))) {
                Annotation("", coordinate: .init(latitude: location.latitude, longitude: location.longitude)) {
                    Image(.makerMineSelected)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .frame(height: UIScreen.main.bounds.size.width * 0.5)
            .padding()
           
       
            LazyVStack(spacing: 12) {
                
                ForEach(viewModel.filterList.isEmpty ? Array(zip($viewModel.memoList.indices, $viewModel.memoList)) : Array(zip($viewModel.filteredMemoList.indices, $viewModel.filteredMemoList)), id:\.0) { index, item in
                    
                    NavigationLink {
                        
                        DetailView(memo: item,
                                   isVisble: .constant(true),
                                   memos:viewModel.filterList.isEmpty ? $viewModel.memoList: $viewModel.filteredMemoList,
                                   selectedMemoIndex: index
                        )
                        
                    } label: {
                        if !viewModel.memoWriterList.isEmpty, index < viewModel.memoWriterList.count {
                            MemoCard(memo: item,
                                     isVisible: true,
                                     profile: viewModel.filterList.isEmpty ? $viewModel.memoWriterList[index] :
                                        $viewModel.filteredProfileList[index],
                                     isPlacePage: true
                            ) { actions in
                                switch actions {
                                case .follow:
                                    print("follow!")
                                    viewModel.fetchMemoProfiles()
                                case .like:
                                    print("liked!")
                                case .unAuthorized:
                                    presentLoginAlert.toggle()
                                case .navigate(profile: let profile):
                                    selectedUser = profile
                                    print("Navigate to \(profile.name)'s profile")
                                default :
                                    print("selected\(actions)")
                                }
                            }
                        }
                    }
                }
            }
            .refreshable {
                viewModel.fetchMemos(of: buildingName)
                viewModel.fetchMemoProfiles()
            }
            .frame(maxWidth: .infinity)
          
             
        }
        
        .moahAlert(isPresented: $presentLoginAlert) {
                    MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                                  firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
                    }),
                                  secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                        self.presentLoginView = true
                    })
                    )
                }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView()
        }
        .onAppear {
            viewModel.fetchMemos(of: buildingName)
            viewModel.fetchMemoProfiles()
        }
        .customNavigationBar(
            centerView: {
                Text("\(buildingName)에 쌓인 메모")
                    .font(.bold16)
            },
            leftView: {
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: .bgColor
        )
         
    }
}

