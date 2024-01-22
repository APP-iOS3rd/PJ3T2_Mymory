//
//  MyPageView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import SwiftUI

struct MypageView: View {
    @StateObject var myPageViewModel: MypageViewModel = .init()
 
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.lightGray
                .edgesIgnoringSafeArea(.top)
              
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .leading) {
                    
                    MypageTopView()
                        .environmentObject(myPageViewModel)
                    
                    if myPageViewModel.isCurrentUserLoginState {
                        
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
                            .disabled(!myPageViewModel.isCurrentUserLoginState)
                        }
                        .padding(.top, 38)
                        
                        MypageMemoList(memoList: $myPageViewModel.memoList)
                            
                        
                    } else {
                        VStack(alignment: .center) {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("로그인이 필요해요!")
                                    .font(.semibold20)
                                Spacer()
                            }
                            NavigationLink {
                                LoginView()
                                    .customNavigationBar(
                                        centerView: {
                                            Text(" ")
                                        },
                                        leftView: {
                                            EmptyView()
                                        },
                                        rightView: {
                                            CloseButton()
                                        },
                                        backgroundColor: .white
                                    )
                                
                            } label: {
                                Text("로그인 하러가기")
                            }
                            
                            Spacer()
                        }
                        
                    }
                }
            }
            .padding(.horizontal, 24)
            .safeAreaInset(edge: .top) {
                Color.clear
                    .frame(height: 0)
                    .background(Color.lightGray)

            }
            .safeAreaInset(edge: .bottom) {
                Color.white
                    .frame(height: 0)
                    .background(.white)
                    .border(Color.black)

            }
 
          
        }
        .onAppear {
            myPageViewModel.isCurrentUserLoginState = myPageViewModel.fetchCurrentUserLoginState()
            myPageViewModel.userInfo = myPageViewModel.fetchUserInfoFromUserDefaults()
        }
    
                
        
    
        
    }
}
