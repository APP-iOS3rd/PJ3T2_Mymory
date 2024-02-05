import SwiftUI
import Kingfisher
struct MemoDetailView: View {
    @State private var selectedNum: Int = 0
    @State private var isHeart: Bool = false
    @State private var isBookmark: Bool = false
    @State private var isShowingSheet: Bool = false
    @State private var isReported: Bool = false
    @State private var isShowingImgSheet: Bool = false
    @State private var isMyMemo:Bool = false
    @Binding var memo: Memo
    @State var memos: [Memo] = [Memo(userUid: "123", title: "ggg", description: "gggg", address: "서울시 @@구 @@동", tags: ["ggg", "Ggggg"], images: [], isPublic: false, date: Date().timeIntervalSince1970 - 1300, location: Location(latitude: 0, longitude: 0), likeCount: 10, memoImageUUIDs: [""])]
    @State var selectedMemoIndex: Int?
    @State var filteredMemos: [Memo]?
    @State private var scrollIndex: Int?
    @StateObject var viewModel: DetailViewModel = DetailViewModel()
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(Array(zip(memos.indices, memos)), id: \.0) { index, memo in
                    ZStack {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ScrollView(.horizontal) {
                                    LazyHGrid(rows: [.init(.flexible())], spacing: 5) {
                                        ForEach(memo.tags, id: \.self) { tag in
                                            Text("#\(tag)")
                                                .font(.semibold12)
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 6)
                                                .foregroundColor(.textColor)
                                                .background(
                                                    Capsule()
                                                        .foregroundColor(.peach)
                                                )
                                            
                                        }
                                    }
                                }
                                .scrollDisabled(false)
                                .frame(maxWidth: .infinity)
                                .aspectRatio(contentMode: .fit)
                                .padding(.leading, 25)
                                
                                
                                HStack{
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(memo.title)
                                            .font(.bold20)
                                        Text(memo.address)
                                            .font(.regular14)
                                            .foregroundStyle(Color.textGray)
                                        
                                        Text("등록 수정일 : \(memo.date.createdAtTimeYYMMDD)")
                                            .font(.regular14)
                                            .foregroundStyle(Color.textGray)
                                    }
                                    Spacer()
                                }.padding(.leading, 25)
                                
                                
                                
                                ScrollView(.horizontal) {
                                    HStack{
                                        ForEach(memo.images.indices, id: \.self) { i in
                                            if let uiimage =  UIImage(data: memo.images[i]) {
                                                Image(uiImage: uiimage)
                                                    .resizable()
                                                //.scaledToFit()
                                                    .scaledToFill()
                                                    .frame(width: 90, height: 90)
                                                    .onTapGesture {
                                                        didTapImage(img: i)
                                                    }
                                                    .fullScreenCover(isPresented: self.$isShowingImgSheet) {
                                                        ImgDetailView(selectedImage: $selectedNum, images: memo.images)
                                                    }
                                            }
                                        }
                                    }
                                }
                                .scrollDisabled(false)
                                .padding(.top, 25)
                                .padding(.leading, 25)
                                
                                Text(memo.description)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 25)
                                
                                    .padding(.horizontal, 25)
                                    .padding(.bottom, 70)
                                Spacer()
                            }
                            //.padding(.top, 50)
                            
                        }
                        
                        
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text("이전 글...")
                                    .font(.regular16)
                                    .frame(width: 100, height: 60)
                                    .onTapGesture {
                                        if selectedMemoIndex != memos.startIndex {
                                            preButton()
                                        }
                                    }
                                
                                Spacer()
                                
                                Text("다음 글...")
                                    .font(.regular16)
                                    .frame(width: 100, height: 60)
                                    .onTapGesture {
                                        if selectedMemoIndex != memos.endIndex - 1 {
                                            nextButton()
                                        }
                                    }
                            }
                            .padding(.horizontal, 20)
                            
                            MoveUserProfileButton(viewModel: viewModel)
                        }
                        .onAppear {
                            Task {
                                do {
                                    viewModel.fetchMemoCreator(uid: memo.userUid)
                                    isMyMemo = try await MemoService().checkMyMemo(checkMemo: memo)
                                } catch {
                                    // 에러 처리
                                    print("Error checking my memo: \(error.localizedDescription)")
                                }
                            }
                        }
                        
                    }//: 내부 ZSTACK
                    .frame(width: UIScreen.main.bounds.size.width)
                }
            }//LazyHSTACK
            .scrollTargetLayout() // 기본값 true, 스크롤 시 개별 뷰로 오프셋 정렬
        } //:SCROLL
        
       .onAppear {
           Task {
               do {
                   isMyMemo = try await MemoService().checkMyMemo(checkMemo: memo)
                   viewModel.fetchMemoCreator(uid: memo.userUid)
               } catch {
                   // 에러 처리
                   print("Error checking my memo: \(error.localizedDescription)")
               }
           }
        }
                   
        .scrollDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollPosition(id: $selectedMemoIndex)
 
        .customNavigationBar(
            centerView: {
                Text(" ")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                NavigationBarItems(isHeart: $isHeart, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: $memo)
            },
            backgroundColor: .bgColor
        )

    }
    func didTapImage(img: Int) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
    
    func checkMyMemo() async {
        isMyMemo = await MemoService().checkMyMemo(checkMemo: memo)
    }
    
    func preButton() {
        if var value = selectedMemoIndex {
            value -= 1
            withAnimation(.default) {
                selectedMemoIndex = value
            }
        }
        
    }
    
    func nextButton() {
        if var value = selectedMemoIndex {
            value += 1
            withAnimation(.default) {
                selectedMemoIndex = value
            }
        }
    }
    
}
