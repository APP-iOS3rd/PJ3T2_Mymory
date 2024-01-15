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
                            .foregroundStyle(Color(hexString: "d9d9d9"))
                        
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
                            
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 24))
                        }
                    }
                    .padding(.top, 38)
                    
                    MemoList(memoList: $myPageViewModel.memoList)
                }
                .padding(.horizontal, 24)
            }
            .background(Color(hexString: "FAFAFA"))
        }
    }
}
