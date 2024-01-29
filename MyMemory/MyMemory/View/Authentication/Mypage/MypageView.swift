//
//  MyPageView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/4/24.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

enum SortedTypeOfMemo: String, CaseIterable, Identifiable {
    case last = "최신순"
    case like = "좋아요순"
    case close = "가까운순"
    
    var id: SortedTypeOfMemo { self }
}

struct MypageView: View {
    @Binding var selected: Int
    @ObservedObject var viewModel: MypageViewModel = .init()
    @State var presentLoginAlert: Bool = false
    @State var presentLoginView: Bool = false
    @ObservedObject var authViewModel: AuthViewModel = .shared
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Color.lightGray
                .edgesIgnoringSafeArea(.top)
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading) {
                    
                    MypageTopView(viewModel: viewModel)
                    
                    if authViewModel.currentUser != nil && UserDefaults.standard.string(forKey: "userId") != nil  {
                        
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
                            .disabled(!(authViewModel.userSession?.uid == UserDefaults.standard.string(forKey: "userId") ))
                        }
                        .padding(.top, 38)
                        
                        MypageMemoList(memoList: $viewModel.memoList)
                            .environmentObject(viewModel)
                        
                        
                    } else {
                        VStack(alignment: .center) {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                Text("로그인이 필요해요!")
                                    .font(.semibold20)
                                Spacer()
                            }
                            Button{
                                self.presentLoginView = true
                            } label: {
                                Text("로그인 하러가기")
                            }
                            
                            Spacer()
                        }
                        
                    }
                }
            }
            .refreshable {
                viewModel.currentLocation = nil
                viewModel.fetchCurrentUserLocation { location in
                    if let location = location, viewModel.currentLocation != location {
                        viewModel.currentLocation = location
                    }
                }
                viewModel.fetchMyMemoList()
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
        .onAppear(perform: {
            Task {
                if UserDefaults.standard.string(forKey: "userId") != nil {
                    presentLoginAlert = false
                } else {
                    presentLoginAlert = true
                }
            }
        })
        .alert("로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?", isPresented: $presentLoginAlert) {
            Button("로그인 하기", role: .destructive) {
                self.presentLoginView = true
            }
            Button("둘러보기", role: .cancel) {
                self.selected = 0
            }
        }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView()
        }
        .overlay {
            if LoadingManager.shared.phase == .loading {
                LoadingView()
            }
        }
        
        //        .onAppear{
        //            viewModel.
        //        }
        //
        //        .onAppear {
        //            viewModel.isCurrentUserLoginState = viewModel.fetchCurrentUserLoginState()
        //            //viewModel.userInfo = viewModel.fetchUserInfoFromUserDefaults()
        //        }
        //
        
        
        
        
    }
}
