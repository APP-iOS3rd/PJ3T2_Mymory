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
    
    @StateObject var locationHandler = LocationsHandler.shared
    @StateObject var viewModel: PlaceViewModel = PlaceViewModel()
    
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
        }
        .customNavigationBar(
            centerView: {
                Text("\(buildingName)에 쌓인 메모")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: .bgColor3
        )
        .onAppear {
            self.viewModel.location = location
            
        }
    }
}

//#Preview {
//    PlaceView()
//}
