//
//  MapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/26/24.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI
struct MapView: View {
    @EnvironmentObject var viewModel: MainMapViewModel
    var body: some View {
        ZStack {
            Map(position: $viewModel.mapPosition,
                interactionModes: .all) {
                if let loc = viewModel.location{
                    Annotation("", coordinate: loc.coordinate) {
                        Image(.mapIcoMarker)
                            .resizable()
                            .frame(width: 20,height: 20)
                            .shadow(radius: 5)
                    }
                }
                ForEach(viewModel.clusters) { cluster in
                    if let userId = UserDefaults.standard.string(forKey: "userId") {
                        if cluster.memos.contains(where:{$0.userUid == userId}) {
                            Annotation("", coordinate: cluster.center) {
                                Image(.markerMine)
                            }
                        } else {
                            Annotation("", coordinate: cluster.center) {
                                Image(.markerDefault)
                            }
                        }
                    } else {
                        Annotation("", coordinate: cluster.center) {
                            Image(.markerDefault)
                        }
                    }
                }//foreach
            }//map
                .onMapCameraChange { context in
                    
                }
        }
    }
}
#Preview {
    MapView()
        .environmentObject(MapViewModel())
}
