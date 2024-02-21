import SwiftUI

struct MemoDetailView: View {
    @State private var selectedNum: Int = 0
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    @State private var isMyMemo:Bool = false
    
    @State private var presentLoginAlert: Bool = false
    @State private var presentLoginView: Bool = false
    @Binding var memos: [Memo]
    @State var selectedMemoIndex: Int?
    @State var isFromCo: Bool = false
    
    
    @StateObject var viewModel: DetailViewModel = DetailViewModel()
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(Array(zip(memos.indices, memos)), id: \.0) { index, memo in
                    ZStack {
                        if let loc = viewModel.locationsHandler.location?.coordinate.distance(from: memo.location)  {
                            
                            if loc >= MemoService.shared.readableArea && !isMyMemo && !isFromCo{
                                VStack(spacing: 10) {
                                    Image(systemName: "lock")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                        .frame(width: 60, height: 60)
                                        .background(Color.bgColor2)
                                        .clipShape(Circle())
                                    
                                    Text("거리가 멀어서 볼 수 없어요.")
                                        .font(.regular18)
                                        .foregroundColor(Color.darkGray)
                                }
                            } else {
                                ScrollView {
                                    DetailViewMemoMoveButton(memos: $memos, selectedMemoIndex: $selectedMemoIndex)
                                     .background(LinearGradient(gradient: 
                                                                Gradient(colors: [Color.cardColor.opacity(0),
                                                                                       Color.cardColor.opacity(0.7),
                                                                                       Color.cardColor.opacity(1)]),
                                                                startPoint: .top,
                                                                endPoint: .bottom)
                                                )
                                    DetailViewListCell(
                                        selectedNum: $selectedNum,
                                        isShowingImgSheet: $isShowingImgSheet,
                                        memo: memo 
                                    )
                                    
                                    .padding()
                                    Spacer()
                                  
                                }
                               // .padding(.top, 30)
                                .refreshable {
                                    Task { @MainActor in
                                        let memo = self.memos[selectedMemoIndex!]
                                        do {
                                            if let newMemo = try await MemoService.shared.fetchMemo(id: memo.id!) {
                                                self.memos[selectedMemoIndex!] = newMemo
                                            }
                                        } catch {}
                                    }
                                }
                            }
                        }
 
                        
                    }//: 내부 ZSTACK
                    .frame(width: UIScreen.main.bounds.size.width)
                    .onAppear {
                        Task {
                            await checkMyMemo()
                            viewModel.fetchMemoCreator(uid: memo.userUid)
                        }
                    }
                    .fullScreenCover(isPresented: $isShowingImgSheet) {
                        ImgDetailView(selectedImage: $selectedNum, images: memo.imagesURL)
                    }
                }
            }//LazyHSTACK
            .scrollTargetLayout() // 기본값 true, 스크롤 시 개별 뷰로 오프셋 정렬
            .background(Color.bgColor3)

        } //:SCROLL
        .onAppear {
            Task {
                do {
                    let memo = memos[selectedMemoIndex!]
                    
                    isMyMemo = try await MemoService.shared.checkMyMemo(checkMemo: memo)
                    if let newMemo = try await MemoService.shared.fetchMemo(id: memo.id!){
                        self.memos[selectedMemoIndex!] = newMemo
                    }
                    viewModel.fetchMemoCreator(uid: memo.userUid)
                } catch {
                    // 에러 처리
                    print("Error checking my memo: \(error.localizedDescription)")
                }
            }
        }
        .background(Color.bgColor)
        .fullScreenCover(isPresented: $presentLoginView) {
            LoginView().environmentObject(AuthViewModel())
        }
        .moahAlert(isPresented: $presentLoginAlert) {
            MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                          firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
            }),
                          secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                self.presentLoginView = true
            })
            )
        }
        .scrollDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $selectedMemoIndex)
        .customNavigationBar(
            centerView: {
                Text("")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                NavigationBarItems(isHeart: $isHeart, unAuthorized: $presentLoginAlert, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: $memos[selectedMemoIndex!])
            },
            backgroundColor: .bgColor3
        )
    }
   
    func checkMyMemo() async {
        let memo = memos[selectedMemoIndex!]
        isMyMemo = await MemoService().checkMyMemo(checkMemo: memo)
    }
}
