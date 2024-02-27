import SwiftUI
import FirebaseAuth
import AuthenticationServices

enum SortedTypeOfMemo: String, CaseIterable, Identifiable {
    case last = "최신순"
    case like = "좋아요순"
    case close = "가까운순"
    
    var id: SortedTypeOfMemo { self }
}

struct OtherUserProfileView: View {
    @State private var presentLoginAlert = false
    @State private var presentLoginView = false
    
    @ObservedObject var authViewModel: AuthService = .shared
    @StateObject var otherUserViewModel: OtherUserViewModel = .init()
    
    @State var selectedIndex = 0
    @State var memoCreator: User
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .top) {
                Color.bgColor
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        OtherUserTopView(memoCreator: $otherUserViewModel.memoCreator)
                        
                            .padding(.horizontal, 14)
                            .padding(.top, 30)
                            .id(0)
                        
                        if otherUserViewModel.memoList.isEmpty {
                            Spacer()
                            // Fetch 한 결과도 empty일때 emptyview 보여줘야함
                            if otherUserViewModel.isEmptyView {
                                OtherUserEmptyView(userName: otherUserViewModel.memoCreator?.name ?? "")
                                    .padding(.top, 30)
                            } else {
                                ProgressView()
                            }
                            Spacer()
                        } else {
                            LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                                Section {
                                    switch selectedIndex {
                                    case 0:
                                        createHeader()
                                            .padding(.bottom)
                                            .padding(.horizontal)
                                        ProfileMemoList<OtherUserViewModel>()
                                            .environmentObject(otherUserViewModel)
                                           
                                    default:
                                        MapImageMarkerView<OtherUserViewModel>()
                                            .environmentObject(otherUserViewModel)
                                         
                                    }
                                } header: {
                                    MenuTabBar(menus: [
                                        MenuTabModel(index: 0, image: "rectangle.grid.1x2.fill"),
                                        MenuTabModel(index: 1, image: "newspaper")
                                    ], selectedIndex: $selectedIndex,
                                               fullWidth: UIScreen.main.bounds.width,
                                               spacing: 50,
                                               horizontalInset: 91.5)
                                    .ignoresSafeArea(edges: .top)
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                .refreshable {
                                    // Refresh logic
                                }
                            } // Lazy
                        }
                    }
                    .refreshable {
                        Task {
                            await otherUserViewModel.fetchMemoCreatorProfile(memoCreator: memoCreator)
                        }
                    }
                }
                
                if !otherUserViewModel.memoList.isEmpty {
                    VStack {
                        Spacer()
                        
                        HStack{
                            Spacer()
                            Button{
                                withAnimation {
                                    proxy.scrollTo(0, anchor: .top)
                                }
                            }label: {
                                Image(.scrollTop)
                            }.padding([.trailing,.bottom] , 30)
                        }
                    }
                }
            }
        }
        .onAppear {
            checkLoginStatus()
            authViewModel.fetchUser()
            
            Task {
                await otherUserViewModel.fetchMemoCreatorProfile(memoCreator: memoCreator)
            }
        }
        .moahAlert(isPresented: $presentLoginAlert) {
            MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                          firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
                self.dismiss()
            }),
                          secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                self.presentLoginView = true
            })
            )
        }
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView()
        }
        .overlay {
            if LoadingManager.shared.phase == .loading {
                LoadingView()
                    .foregroundStyle(Color.textColor)
                    .font(.semibold16)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(otherUserViewModel.memoCreator?.name ?? "")
            }
            ToolbarItem(placement: .topBarTrailing) {
                EmptyView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func createHeader() -> some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading) {
                Text("\(otherUserViewModel.memoCreator?.name ?? "")님이 작성한 메모")
                    .font(.semibold20)
                    .foregroundStyle(Color.textColor)
                Text("\(otherUserViewModel.memoCreator?.name ?? "")님이 선택한 메모만 보여줘요!")
                    .font(.regular14)
                    .foregroundStyle(Color.textDeepColor)
            }

            Spacer()
            
            Button {
                otherUserViewModel.isShowingOptions.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 24))
            }
            .confirmationDialog("정렬하고 싶은 기준을 선택하세요.", isPresented: $otherUserViewModel.isShowingOptions) {
                ForEach(SortedTypeOfMemo.allCases, id: \.id) { type in
                    Button(type.rawValue) {
                        otherUserViewModel.sortMemoList(type: type)
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
