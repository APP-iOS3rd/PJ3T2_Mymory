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
        if let _ = authViewModel.currentUser, let userId = UserDefaults.standard.string(forKey: "userId") {
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    Color.bgColor
                        .ignoresSafeArea()
                    
                    VStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            MypageTopView()
                                .padding(.horizontal, 14)
                                .id(0)
                            if mypageViewModel.memoList.isEmpty {
                                Spacer()
                                // Fetch 한 결과도 empty일때 emptyview 보여줘야함
                                if mypageViewModel.isEmptyView {
                                    MyPageEmptyView(selectedIndex: $selected)

                                } else {
                                    ProgressView()
                                }
                                Spacer()
                            } else {
                                LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                                    Section {
                                        if let currentUser = authViewModel.currentUser, let userId = UserDefaults.standard.string(forKey: "userId") {
                                            let isCurrentUser = authViewModel.userSession?.uid == userId
                                            
                                            switch selectedIndex {
                                            case 0:
                                                createHeader()
                                                    .padding(.bottom)
                                                    .padding(.horizontal)
                                                   // .border(width: 1, edges: [.bottom], color: .borderColor)
                                                ProfileMemoList<MypageViewModel>().environmentObject(mypageViewModel)
                                            default:
                                                MapImageMarkerView<MypageViewModel>().environmentObject(mypageViewModel)
                                            }
                                        }
                                    } header: {
                                        MenuTabBar(menus: [MenuTabModel(index: 0, image: "rectangle.grid.1x2.fill"), MenuTabModel(index: 1, image: "map")],
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
                                    isRefreshing = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        mypageViewModel.fetchUserMemo()
                                        isRefreshing = false
                                    }
                                }
                            }
                        } //: ScrollView
                        .padding(.top)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    proxy.scrollTo(0, anchor: .top)
                                }
                            } label: {
                                Image(.scrollTop)
                            }
                            .padding([.trailing, .bottom], 30)
                        }
                    }
                }
            }
            .refreshable {
                // Refresh logic
                isRefreshing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    mypageViewModel.fetchUserMemo()
                    isRefreshing = false
                }
            }
            .onAppear {
                checkLoginStatus()
                authViewModel.fetchUser()
                mypageViewModel.fetchUserMemo()

                // Add your other onAppear logic here
            }
            // Add your other onAppear and alert code here
        } else {
            showLoginPrompt()
                .fullScreenCover(isPresented: $presentLoginView) {
                    LoginView()
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
        }.background(Color.bgColor)
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

