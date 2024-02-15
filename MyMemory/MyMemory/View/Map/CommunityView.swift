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
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("반응이 많은\n메모")
                        .font(.bold24)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding(.horizontal, 25)
                    .padding(.top, 25)
                ScrollView(.horizontal){
                    LazyHStack(spacing: 0, content: {
                        ForEach($viewModel.memosOfTheWeek) { memo in
                            MemoCell(location: $locationManager.location,memo: memo, memos: $viewModel.memosOfTheWeek, isFromCo: true)
                                .padding(.leading, 18)
                        }
                    })
                    .scrollTargetLayout()
                    
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
                        HStack{
                            VStack(alignment: .leading) {
                                Text("\(building.buildingName)")
                                    .font(.bold16)
                                    .foregroundStyle(Color.textColor)
                                    .padding(.bottom,5)
                                Text("\(building.address)")
                                    .font(.regular12)
                                    .foregroundStyle(Color.textColor)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 15)

                            Spacer()
                            Button{

                            } label: {
                                VStack {
                                    
                                    Text("\(building.count)개의 메모")
                                        .font(.regular12)
                                        .foregroundStyle(Color.textColor)
                                        .padding()
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 15)
                        }

                        .background(Color.cardColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.borderColor)
                        )

                    }
                }).padding(.horizontal, 25)
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
