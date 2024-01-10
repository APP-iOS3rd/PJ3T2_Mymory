//
//  PostView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/4/24.
//

import SwiftUI
import MapKit


@available(iOS 17.0, *)

// 💁 사용자 위치추적 및 권한허용 싱글톤 구현 위치 임시지정
@MainActor class LocationsHandler: ObservableObject {
    
    static let shared = LocationsHandler()
    public let manager: CLLocationManager

    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}


@available(iOS 17.0, *)
struct PostView: View {
    
    // 사용자 위치 값 가져오기
    @ObservedObject var locationsHandler = LocationsHandler.shared
    
    // 카메라 위치추적 변수 사용자를 추적
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    // LazyHGrid GridItem
    // 화면 그리드 형식으로 채워줌 임시변수
    let layout: [GridItem] = [
        GridItem(.flexible(maximum: 80)),
    ]
    
    let memoList: [String] = Array(1...10).map {"메모 \($0)"}
    
    var body: some View {
      
        VStack(alignment: .leading){
            Map(position: $position){
                UserAnnotation()
            }
            .overlay(content: {
                Button(action: {
                    //💁 MemoView 이동 로직 작성
                }) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight : .infinity, alignment: .bottomTrailing)
        
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 5))
            })
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .background(.white)
            .padding(.bottom)
            .safeAreaInset(edge: .bottom) {
                // 💁 메모 표시될 영역
                ScrollView(.horizontal) {
                    // 가로(행) 3줄 설정
                    LazyHGrid(rows: layout, spacing: 20) {
                        ForEach(memoList, id: \.self) { item  in
                            VStack {
                                MemoCell()
                                    .frame(height: UIScreen.main.bounds.size.height * 0.10)
                                    .frame(width: UIScreen.main.bounds.size.width * 0.90)
                                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 20))
                            }
                        }
                    }     //: LazyHGrid
                }  //: ScrollView
                .frame(height: UIScreen.main.bounds.size.height * 0.18) // 18%만
            }
            .background(.white)
            
        
        } //:VSTACK

    }
       
}

#if DEBUG
@available(iOS 17.0, *)
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
#endif

