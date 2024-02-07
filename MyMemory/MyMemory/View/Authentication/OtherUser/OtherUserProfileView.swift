
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
    @State private var fromDetail = false
    @ObservedObject var otherUserViewModel: OtherUserViewModel = .init()
    
    @State var selectedIndex = 0
    @State var user: User
    // 생성자를 통해 @State를 만들수 있도록 fromDetail true면 상대방 프로필 가져오기
    init(fromDetail: Bool, memoCreator: User) {
        self._fromDetail = State(initialValue: fromDetail)
        self.user = memoCreator
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgColor.edgesIgnoringSafeArea(.top)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    // 로그인 되었다면 로직 실행
                    if let currentUser = authViewModel.currentUser, let userId = UserDefaults.standard.string(forKey: "userId") {
                        let isCurrentUser = authViewModel.userSession?.uid == userId
                        
                        // 상대방 프로필을 표시할 때는 제네릭을 사용하여 OtherUserViewModel을 전달 MyPage를 표시할 때는 MypageViewModel 전달
                        if fromDetail == true && otherUserViewModel.memoCreator.isCurrentUser == false  {
                            OtherUserTopView(memoCreator: $otherUserViewModel.memoCreator, viewModel: otherUserViewModel)
                            createHeader()
                            
                            ProfileMemoList<OtherUserViewModel>().environmentObject(otherUserViewModel)
                        }
                        else {
                            MyPageView()
                        }
                    }
                    else {
                        showLoginPrompt()
                    }
                }
                
            }
            .refreshable {
                // Refresh logic
            }
            .padding(.horizontal, 14)
            .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0).background(Color.bgColor)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0).background(Color.bgColor).border(Color.black)
            }
        }
        .onAppear {
            checkLoginStatus()
            authViewModel.fetchUser()
            otherUserViewModel.fetchMemoCreatorProfile(fromDetail: fromDetail, memoCreator: user)

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
            LoginView().environmentObject(authViewModel)
        }
        .overlay {
            if LoadingManager.shared.phase == .loading {
                LoadingView()
            }
        }
    }
    
    private func createHeader() -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text("\(otherUserViewModel.memoCreator.name)님이 작성한 메모")
                .font(.semibold20)
                .foregroundStyle(Color.textColor)
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
