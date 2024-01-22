//
//  MyPageView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import SwiftUI

struct MypageView: View {
    
    let user: User
    @ObservedObject var viewModel: MypageViewModel
    @ObservedObject var authViewModel: AuthViewModel
    // @StateObject var myPageViewModel: MypageViewModel = .init()
 
    init(user: User) {
        self.user = user
        self.viewModel = MypageViewModel(user: user)
        self.authViewModel = AuthViewModel()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.lightGray
                .edgesIgnoringSafeArea(.top)
              
            ScrollView(.vertical, showsIndicators: false){
                
                VStack(alignment: .leading) {
                    
                    MypageTopView(viewModel: viewModel, authViewModel: authViewModel)
                    
                    
                    if authViewModel.currentUser != nil {
                        
                        HStack(alignment: .lastTextBaseline) {
                            Text("내가 작성한 메모")
                                .font(.semibold20)
                            
                            Spacer()
                            
                            Button {
                                viewModel.isShowingOptions.toggle()
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .foregroundStyle(Color.gray)
                                    .font(.system(size: 24))
                            }
                            .confirmationDialog("정렬하고 싶은 기준을 선택하세요.", isPresented: $viewModel.isShowingOptions) {
                                ForEach(SortedTypeOfMemo.allCases, id: \.id) { type in
                                    Button(type.rawValue) {
                                        viewModel.sortMemoList(type: type)
                                    }
                                }
                            }
                            .disabled(!viewModel.isCurrentUserLoginState)
                        }
                        .padding(.top, 38)
                        
                        MypageMemoList(memoList: $viewModel.memoList)
                           
                        
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
        
//        .onAppear {
//            viewModel.isCurrentUserLoginState = viewModel.fetchCurrentUserLoginState()
//            //viewModel.userInfo = viewModel.fetchUserInfoFromUserDefaults()
//        }
//    
                
        
    
        
    }
}
