//
//  MyPageView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import SwiftUI

struct MypageView: View {
    @StateObject var myPageViewModel = MypageViewModel.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Circle()
                            .frame(width: 76, height: 76)
                            .foregroundStyle(Color(hex: "d9d9d9"))
                        
                        Text("닉네임")
                            .font(.semibold20)
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        NavigationLink {
                            SettingView()
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.top, 30)
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text("내가 작성한 메모")
                            .font(.semibold20)
                        
                        Spacer()
                        
                        Button {
                            myPageViewModel.isShowingOptions.toggle()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 24))
                        }
                        .confirmationDialog("정렬하고 싶은 기준을 선택하세요.", isPresented: $myPageViewModel.isShowingOptions) {
                            ForEach(SortedTypeOfMemo.allCases, id: \.id) { type in
                                Button(type.rawValue) {
                                    myPageViewModel.sortMemoList(type: type)
                                }
                            }
                        }
                    }
                    .padding(.top, 38)
                    
                    MypageMemoList(memoList: $myPageViewModel.memoList)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(hex: "FAFAFA"))
        }
    }
}
