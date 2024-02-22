//
//  MapMemoList.swift
//  MyMemory
//
//  Created by 정정욱 on 2/5/24.
//

import SwiftUI
import MapKit
import Kingfisher

struct MapImageMarkerView<ViewModel: ProfileViewModelProtocol>: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var position: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)
    
    var body: some View {
        VStack {
            Map(position: $position) {
                ForEach($viewModel.memoList, id: \.id) { memo in
                    
                    let location = CLLocationCoordinate2D(
                        latitude: Double(memo.location.latitude.wrappedValue),
                        longitude: Double(memo.location.longitude.wrappedValue)
                    )
                    
                    Annotation(memo.title.wrappedValue, coordinate: location) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.background)
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.secondary, lineWidth: 5)
                            if memo.imagesURL.count > 0 {
                                KFImage(URL(string: memo.imagesURL.first!.wrappedValue))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                            }
                        }
                        
                        
                    }
                }
                .annotationTitles(.hidden) // 제목 감추기
            }
            .mapControls { // 이제 버튼을 탭하여 내 위치를 표시할 수 있습니다. 내가 움직일 때 지도 카메라가 나를 따라다닐 것입니다.
                       MapUserLocationButton() // 누르면 내 위치로 바로 이동함, 내가 이동하면 카메라도 이동함
                       MapCompass()
                       MapScaleView()
                       /*
                        mapControls 설정은 지도를 회전하면 나침반을 띄우고 화면을 확대하거나 축소하면 축적을 표시함
                        */
            }
            .frame(height: 400)
            

        }
    }
}

//#Preview {
//    MapImageMarkerView()
//}
