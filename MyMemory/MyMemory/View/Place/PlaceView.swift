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
    @StateObject var locationHandler = LocationsHandler.shared
    @StateObject var viewModel: PlaceViewModel = .init()
    @State var selectedUser: Profile? = nil
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    var body: some View {
        ScrollView(.vertical){            
            Map(initialPosition: .region(MKCoordinateRegion(center: coordinate, span: (MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))))) {
                Annotation("", coordinate: .init(latitude: location.latitude, longitude: location.longitude)) {
                    Image(.makerMineSelected)
                }
            }
            .clipShape(.rect(cornerRadius: 10))
            .frame(height: UIScreen.main.bounds.size.width * 0.5)
            .padding()
           
            ScrollView(.vertical, showsIndicators: false){
                LazyVStack(spacing: 12) {
                    ForEach(Array(zip($viewModel.memoList.indices, $viewModel.memoList)), id:\.0) { index, item in
                        
                        NavigationLink {
                            
                            DetailView(memo: item,
                                       isVisble: .constant(true),
                                       memos: $viewModel.memoList,
                                       selectedMemoIndex: index
                            )
                            
                        } label: {
                            if !viewModel.memoWriterList.isEmpty {
                                MemoCard(memo: item,
                                         isVisible: true,
                                         profile: $viewModel.memoWriterList[index]) { actions in
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
                    viewModel.fetchMemos()
                    viewModel.fetchMemoProfiles()
                }
                .frame(maxWidth: .infinity)
            }
             
        }
        .onAppear {
          
            viewModel.setLocation(location: CLLocation(latitude: location.latitude, longitude: location.longitude))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                viewModel.fetchMemos()
                viewModel.fetchMemoProfiles()
            }
           
             
            
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
            backgroundColor: .bgColor3
        )
         
    }
}

