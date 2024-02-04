
import SwiftUI
import FirebaseAuth
import AuthenticationServices

enum SortedTypeOfMemo: String, CaseIterable, Identifiable {
    case last = "최신순"
    case like = "좋아요순"
    case close = "가까운순"
    
    var id: SortedTypeOfMemo { self }
}

struct ProfileView: View {
    @State var selected: Int = 2
    @State private var presentLoginAlert = false
    @State private var presentLoginView = false
    
    @ObservedObject var authViewModel: AuthViewModel = .shared
    @State private var fromDetail = false

    @ObservedObject var mypageViewModel: MypageViewModel = .init()
    @ObservedObject var otherUserViewModel: OtherUserViewModel = .init()

    // 생성자를 통해 @State를 만들수 있도록 
    init(fromDetail: Bool, memoCreator: User) {
           self._fromDetail = State(initialValue: fromDetail)
           otherUserViewModel.fetchMemoCreatorProfile(fromDetail: fromDetail, memoCreator: memoCreator)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.bgColor.edgesIgnoringSafeArea(.top)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    if let currentUser = authViewModel.currentUser, let userId = UserDefaults.standard.string(forKey: "userId") {
                        let isCurrentUser = authViewModel.userSession?.uid == userId
                        
                        if fromDetail == true && otherUserViewModel.memoCreator.isCurrentUser == false  {
                            OtherUserTopView(memoCreator: $otherUserViewModel.memoCreator, viewModel: otherUserViewModel)
                            createHeader(isCurrentUser: isCurrentUser)
                            ProfileMemoList<OtherUserViewModel>().environmentObject(otherUserViewModel)
                        } else {
                            MypageTopView() //
                            createHeader(isCurrentUser: isCurrentUser)
                            ProfileMemoList<MypageViewModel>().environmentObject(mypageViewModel)
                        }
                    } else {
                        showLoginPrompt()
                    }
                }
            
            }
            .refreshable {
                // Refresh logic
            }
            .padding(.horizontal, 24)
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
    
    private func createHeader(isCurrentUser: Bool) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text("\(otherUserViewModel.memoCreator.name)님이 작성한 메모").font(.semibold20).foregroundStyle(Color.textColor)
            Spacer()
            
            Button {
                isCurrentUser ? mypageViewModel.isShowingOptions.toggle() : otherUserViewModel.isShowingOptions.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3").foregroundStyle(Color.gray).font(.system(size: 24))
            }
            .confirmationDialog("정렬하고 싶은 기준을 선택하세요.", isPresented: isCurrentUser ? $mypageViewModel.isShowingOptions : $otherUserViewModel.isShowingOptions) {
                ForEach(SortedTypeOfMemo.allCases, id: \.id) { type in
                    Button(type.rawValue) {
                        isCurrentUser ? mypageViewModel.sortMemoList(type: type) : otherUserViewModel.sortMemoList(type: type)
                    }
                }
            }
            .disabled(!isCurrentUser)
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
