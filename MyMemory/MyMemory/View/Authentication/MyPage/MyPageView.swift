
import SwiftUI
import FirebaseAuth
import AuthenticationServices


struct MyPageView: View {
    @Binding var selected: Int
    @State private var presentLoginAlert = false
    @State private var presentLoginView = false
    
    @ObservedObject var authViewModel: AuthService = .shared
    
    @ObservedObject var mypageViewModel: MypageViewModel = .init()
    
    @State var selectedIndex = 0
    @State private var isRefreshing = false

    var body: some View {
        ScrollViewReader { proxy in

        ZStack(alignment: .top) {
            Color.bgColor
                .ignoresSafeArea()
                
            VStack {
                    ScrollView(.vertical, showsIndicators: false) {
//                         MypageTopView()
//                             .padding(.horizontal, 14)
//                             .environmentObject(mypageViewModel)
                        LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                            // 로그인 되었다면 로직 실행
                            Section {
                                
                                if let currentUser = authViewModel.currentUser, let userId = UserDefaults.standard.string(forKey: "userId") {
                                    let isCurrentUser = authViewModel.userSession?.uid == userId
                                    
                                    // 하나씩 추가해서 탭 추가, spacin......g, horizontalInset 늘어나면 값 수정 필요
                                    
                                    MypageTopView()
                                        .padding(.horizontal, 14)
                                    
                                    switch selectedIndex {
                                    case 0:
                                        createHeader()
                                            .padding(.bottom)
                                        if mypageViewModel.memoList.isEmpty {
                                             MyPageEmptyView(selectedIndex: $selected)
                                            
                                        } else {
                                            ProfileMemoList<MypageViewModel>().environmentObject(mypageViewModel)
                                        }
                                    default:
                                        MapImageMarkerView<MypageViewModel>().environmentObject(mypageViewModel)
                                        
                                    }
                                    
                                    
                                }
                                else {
                                    showLoginPrompt()
                                }
                                
                            } header: {
                                MenuTabBar(menus: [MenuTabModel(index: 0, image: "list.bullet.below.rectangle"), MenuTabModel(index: 1, image: "newspaper")],
                                           selectedIndex: $selectedIndex,
                                           fullWidth: UIScreen.main.bounds.width,
                                           spacing: 50,
                                           horizontalInset: 91.5)
                                .ignoresSafeArea(edges: .top)
                                .frame(maxWidth: .infinity)
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        .refreshable {
                            // Refresh logic
                        }
                        //                .safeAreaInset(edge: .top) {
                        //                    Color.clear.frame(height: 0).background(Color.bgColor)
                        //                }
                        //                .safeAreaInset(edge: .bottom) {
                        //                    Color.clear.frame(height: 0).background(Color.bgColor).border(Color.black)
                        //                }
                    } //: scrollView
                    .padding(.horizontal)
                    .padding(.top)
                }
                VStack{
                    Spacer()
                    
                    HStack{
                        Spacer()
                        Button{
                            withAnimation {
                                proxy.scrollTo(0, anchor: .top)
//                                self.scrollPosition = 0.0
                            }
                        }label: {
                            Image(.scrollTop)
                        }.padding([.trailing,.bottom] , 30)
                    }
                }
            }
            
        }
        .refreshable {
            isRefreshing = true
            
            // 새로고침 로직 실행
            
            // 로직이 완료되면 isRefreshing을 false로 설정하여 새로고침 상태를 종료합니다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                mypageViewModel.fetchUserMemo()
                isRefreshing = false
            }
        }
        .onAppear {
            checkLoginStatus()
            authViewModel.fetchUser()
        }
        .alert("로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?", isPresented: $presentLoginAlert) {
            Button("로그인 하기", role: .destructive) {
                self.presentLoginView = true
            }
            Button("둘러보기", role: .cancel) {
                // Handle '둘러보기' case
            }
        }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView().environmentObject(AuthViewModel())
        }
        .overlay {
            if LoadingManager.shared.phase == .loading {
                LoadingView()
            }
        }
    }
    
    private func createHeader() -> some View {
        HStack(alignment: .lastTextBaseline) {
            Spacer()
            
            Button {
                mypageViewModel.isShowingOptions.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3").foregroundStyle(Color.gray).font(.system(size: 24))
            }
            .confirmationDialog("정렬하고 싶은 기준을 선택하세요.", isPresented: $mypageViewModel.isShowingOptions) {
                ForEach(SortedTypeOfMemo.allCases, id: \.id) { type in
                    Button(type.rawValue) {
                        mypageViewModel.sortMemoList(type: type)
                    }
                }
            }
        }
        .padding(.top, 38)
    }
    
    
    private func showLoginPrompt() -> some View {
        VStack(alignment: .center) {
            Spacer()
            
            HStack {
                Spacer()
                Text("로그인이 필요해요!").font(.semibold20)
                Spacer()
            }
            
            Button {
                self.presentLoginView = true
            } label: {
                Text("로그인 하러가기")
            }
            
            Spacer()
        }
    }
    
    private func checkLoginStatus() {
        Task {
            if UserDefaults.standard.string(forKey: "userId") != nil {
                presentLoginAlert = false
            } else {
                presentLoginAlert = true
            }
        }
    }
}


