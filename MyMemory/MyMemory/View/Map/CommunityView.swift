//
//  CommunityView.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct CommunityView: View {
    @StateObject var locationManager = LocationsHandler.shared
    @StateObject var viewModel: CommunityViewModel = .init()
    @State var buildingInfo: [BuildingInfo] = []
    @StateObject var placeViewModel: PlaceViewModel = PlaceViewModel()
    var unAuthorized: (Bool) -> ()
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("반응이 많은\n메모")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 25)
                
                ScrollView(.horizontal){
                    if viewModel.memosOfTheWeek.isEmpty {
                        HStack {
                            ForEach(0..<5, id:\.self) { index in
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color.originColor)
                                    .overlay(ProgressView())
                                    .frame(width: UIScreen.main.bounds.width * 3.0/4.0,
                                           height: UIScreen.main.bounds.width * 3.0/8.0)
                                    .padding(.leading, 18)
                            }
                        }
                    } else {
                        
                        LazyHStack(spacing: 0, content: {
                            ForEach($viewModel.memosOfTheWeek.indices, id:\.self) { index in
                                MemoCell(location: $locationManager.location,
                                         selectedMemoIndex: index,
                                         memo: $viewModel.memosOfTheWeek[index],
                                         memos: $viewModel.memosOfTheWeek,
                                         isFromCo: true) { res in
                                    unAuthorized(res)
                                }
                                         .padding(.leading, 18)
                            }
                            
                        })
                        .scrollTargetLayout()
                    }
                }
                
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .padding(.top, 25)
                
                HStack {
                    Text("이번 주\n가장 핫한 지역")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.horizontal, 25)
                    .padding(.top, 60)
                    .padding(.bottom, 25)
                LazyVStack(spacing: 15, content: {
                    ForEach(buildingInfo, id: \.self) { building in
                        NavigationLink{
                            PlaceView(location: building.location, buildingName: building.buildingName, address: building.address)
                            //    .environmentObject(placeViewModel)
                        } label: {
                            
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("\(building.buildingName)")
                                        .font(.bold16)
                                        .foregroundStyle(Color.textColor)
                                    
                                    Spacer()
                                    Text("\(building.count)개의 메모")
                                        .font(.regular12)
                                        .foregroundStyle(Color.textColor)
                                    
                                }
                                Text("\(building.address)")
                                    .font(.regular12)
                                    .foregroundStyle(Color.textColor)
                                    .lineLimit(1)
                            }
                            .padding()
                            .background(Color.cardColor)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            //                            .overlay(
                            //                                RoundedRectangle(cornerRadius: 10)
                            //                                    .stroke(Color.borderColor)
                            //                            )
                        }
                        
                    }
                })
                .padding(.horizontal, 25)
            }
        }
        .onAppear {
            Task{ @MainActor in
                do {
                    self.buildingInfo = try await MemoService.shared.buildingList().filter{!$0.buildingName.isEmpty}
                    self.buildingInfo.sort(by: {$0.count > $1.count})
                    print(self.buildingInfo)
                } catch {}
            }
        }
        
    }
    
    
    
}
