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
    @Binding var memos: [Memo]
    @State var selectedMemoIndex: Int?
    

    @StateObject var viewModel: DetailViewModel = DetailViewModel()


    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(Array(zip(memos.indices, memos)), id: \.0) { index, memo in
                    ZStack {
                        
                        if let loc = viewModel.locationsHandler.location?.coordinate.distance(from: memo.location)  {
                            
                            if loc >= 50 && !isMyMemo {
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
                                                    .font(.userMainTextFont(baseSize: 20))
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
                                                ForEach(memo.imagesURL.indices, id: \.self) { i in
                                                KFImage(URL(string: memo.imagesURL[i]))
                                                .resizable()
                                                //.scaledToFit()
                                                    .frame(width: 90, height: 90)
                                                    .scaledToFill()
                                                    .onTapGesture {
                                                        didTapImage(img: i)
                                                    }
                                                    .fullScreenCover(isPresented: self.$isShowingImgSheet) {
                                                        ImgDetailView(selectedImage: $selectedNum, images: memo.imagesURL)
                                                    }
                                                }
                                            }                                        }
                                        .scrollDisabled(false)
                                        .padding(.top, 25)
                                        .padding(.leading, 25)
                                        
                                        Text(memo.description)
                                            .multilineTextAlignment(.leading)
                                            .padding(.top, 25)
                                            .font(.userMainTextFont(baseSize: 16))
                                            .padding(.horizontal, 25)
                                            .padding(.bottom, 70)
                                        Spacer()
                                    }
                                    //.padding(.top, 50)
                                    
                                }
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
                        
 
                        VStack {
                            Spacer()
                            
                            HStack {
                                if selectedMemoIndex != memos.startIndex {
                                    
                                    Text("이전 글...")
                                        .font(.regular16)
                                        .frame(width: 100, height: 60)
                                        .onTapGesture {
                                            if selectedMemoIndex != memos.startIndex {
                                                preButton()
                                            }
                                        }
 
                                }
                                Spacer()
                                if selectedMemoIndex != memos.endIndex - 1 {
                                    
                                    Text("다음 글...")
                                        .font(.regular16)
                                        .frame(width: 100, height: 60)
                                        .onTapGesture {
                                            if selectedMemoIndex != memos.endIndex - 1 {
                                                nextButton()
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            MoveUserProfileButton(viewModel: viewModel)
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
                NavigationBarItems(isHeart: $isHeart, isBookmark: $isBookmark, isShowingSheet: $isShowingSheet, isReported: $isReported, isShowingImgSheet: $isShowingSheet, isMyMemo: $isMyMemo, memo: $memos[selectedMemoIndex!])
            },
            backgroundColor: .bgColor
        )
        
    }
    func didTapImage(img: Int) {
        selectedNum = img
        isShowingImgSheet.toggle()
    }
    
    func checkMyMemo() async {
        let memo = memos[selectedMemoIndex!]
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
