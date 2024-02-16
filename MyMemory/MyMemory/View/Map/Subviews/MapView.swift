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
            GeometryReader { proxy in
                Map(position: $viewModel.mapPosition,
                    interactionModes: .all) {
                    if let loc = viewModel.location{
                        Annotation("", coordinate: loc.coordinate) {
                            ZStack {
                                Image(.mapIcoMarker)
                                    .resizable()
                                    .frame(width: 20,height: 20)
                                    .shadow(radius: 5)
                                    
                            }
                        }.mapOverlayLevel(level: .aboveLabels)
                        MapCircle(center: loc.coordinate, radius: MemoService.shared.queryArea)
                            .foregroundStyle(Color(red: 0.98, green: 0.15, blue: 0.15).opacity(0.1))


                    }
                    ForEach(viewModel.clusters) { cluster in
                        //case 1: 로그인 되었을 경우
                        if let userId = UserDefaults.standard.string(forKey: "userId") {
                            //case 2: 클러스터에 내 메모가 있을 경우
                            if cluster.memos.contains(where:{$0.userUid == userId}) {
                                //case 3: 클러스터에 내 메모가 있고, 선택한 경우
                                if let selected = viewModel.selectedMemoId, cluster.memos.contains(where: {$0.id == selected}){
                                    Annotation("", coordinate: cluster.center) {
                                        Image(.makerMineSelected)
                                            .onTapGesture {
                                                viewModel.clusterDidSelected(cluster: cluster)
                                            }
                                    }
                                } else {
                                    Annotation("", coordinate: cluster.center) {
                                        Image(.markerMine)
                                            .onTapGesture {
                                                viewModel.clusterDidSelected(cluster: cluster)
                                            }
                                    }
                                }
                            } else {
                                if let selected = viewModel.selectedMemoId, cluster.memos.contains(where: {$0.id == selected}) {
                                    Annotation("", coordinate: cluster.center) {
                                        Image(.markerSelected)
                                            .onTapGesture {
                                                viewModel.clusterDidSelected(cluster: cluster)
                                            }
                                    }
                                } else {
                                    Annotation("", coordinate: cluster.center) {
                                        Image(.markerDefault)
                                            .onTapGesture {
                                               viewModel.clusterDidSelected(cluster: cluster)
                                           }
                                    }
                                }
                            }
                        } else {
                            if let selected = viewModel.selectedMemoId, cluster.memos.contains(where: {$0.id == selected}) {
                                Annotation("", coordinate: cluster.center) {
                                    Image(.markerSelected)
                                        .onTapGesture {
                                            viewModel.clusterDidSelected(cluster: cluster)
                                        }
                                }
                            } else {
                                Annotation("", coordinate: cluster.center) {
                                    Image(.markerDefault)
                                        .onTapGesture {
                                           viewModel.clusterDidSelected(cluster: cluster)
                                       }
                                }
                            }
                        }
                    }//foreach
                }//map
                    .onMapCameraChange { context in
                        viewModel.setCamera(boundWidth: proxy.size.width, context: context)
                        viewModel.cameraDidChange(boundWidth: proxy.size.width, context: context)
                    }
            }
        }
    }
}
