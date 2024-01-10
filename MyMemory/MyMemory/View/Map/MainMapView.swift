//
//  MainMapView.swift
//  MyMemory
//
//  Created by 김태훈 on 1/2/24.
//

import SwiftUI
import MapKit
struct MainMapView: View {
    @ObservedObject var viewModel: MainMapViewModel = .init()
    var body: some View {
        ZStack {
            MapViewRepresentable()
                .environmentObject(viewModel)
                .ignoresSafeArea(edges: .top)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.switchUserLocation()
                    },
                           label: {
                        Text("내 위치 보기")
                            .foregroundStyle(viewModel.isUserTracking ? Color.blue : Color.black)
                            .font(.bold14)
                            .padding(5)
                    })
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                }
                //선택한 경우
                if let contents = viewModel.selectedCluster {
                    ClusterSelectionView(contents: contents)
                        .environmentObject(viewModel)
                    
                }
            }
        }
    }
}

#Preview {
    MainMapView()
}

struct ClusterSelectionView: View {
    @EnvironmentObject var viewModel: MainMapViewModel
    let contents: MemoCluster
    var body: some View {
        VStack {
            HStack {
                Text(viewModel.selectedAddress ?? "주소가 확인되지 않습니다.")
                    .font(.regular12)
                    .foregroundStyle(Color.gray)
                    .padding([.top, .leading], 25)
                
                Spacer()
            }
            ScrollView(.horizontal) {
                HStack{
                    ForEach(contents.memos) { item in
                        VStack {
                            HStack {
                                Text("\(item.title)")
                                    .lineLimit(1)
                                    .font(.bold20)
                                Spacer()
                                Text("\(item.createdAt.createdAtTimeYYMMDD)")
                                    .font(.regular12)
                                    .foregroundStyle(Color.gray)
                            }
                            .padding([.leading, .trailing], 14)
                            Text(item.contents)
                                .lineLimit(3)
                                .font(.regular14)
                                .frame(maxWidth: .infinity)
                                .padding([.leading,.trailing], 14)
                                .padding(.bottom, 20)
                                .padding(.top, 10)
                        
                        }.frame(width: 300)
                        .padding(.top, 10)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                            .cornerRadius(15)
                            .padding(10)
                            
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedCornersShape(radius: 20,corners: [.topLeft,.topRight]))
    }
}
