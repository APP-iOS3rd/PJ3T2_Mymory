import SwiftUI
import Kingfisher
import CoreLocation

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
    @Binding var location: CLLocation?
    @State var selectedMemoIndex = 0
    
    @StateObject var viewModel: DetailViewModel = DetailViewModel()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedMemoIndex) {
                ForEach(Array(zip(memos.indices, memos)), id: \.0) { index, memo in
                    if let loc = location?.coordinate.distance(from: memo.location) {
                        if loc > 100 && !isMyMemo{
                            VStack {
                                Image(systemName: "lock")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                    .padding()
                                Text("해당 메모는 거리가 멀어서 볼 수 없어요.")
                                    .font(.regular18)
                            }
                        } else {
                            VStack {
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
                                    }.frame(maxWidth: .infinity)
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
                                            ForEach(memo.images.indices, id: \.self) { index in
                                                if let uiimage =  UIImage(data: memo.images[index]) {
                                                    Image(uiImage: uiimage)
                                                        .resizable()
                                                    //.scaledToFit()
                                                        .scaledToFill()
                                                        .frame(width: 90, height: 90)
                                                        .onTapGesture {
                                                            didTapImage(img: index)
                                                        }
                                                        .fullScreenCover(isPresented: self.$isShowingImgSheet) {
                                                            ImgDetailView(isShownFullScreenCover: self.$isShowingImgSheet, selectedImage: $selectedNum, images: memo.images)
                                                      }
                                                }
                                            }
                                        }
                                    }
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
                            
                            
                                Spacer()
                                MoveUserProfileButton(viewModel: viewModel)
                            }
                        }
                    }
                }//foreach
            }//: tabview
            .tabViewStyle(.page(indexDisplayMode: .never))
        } // :zstack
//        .onAppear {
//            Task {
//                do {
//                    isMyMemo = try await MemoService().checkMyMemo(checkMemo: memo)
//                    //viewModel.fetchMemoCreator(uid: memo.userUid)
//                } catch {
//                    // 에러 처리
//                    print("Error checking my memo: \(error.localizedDescription)")
//                }
//            }
//        }

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
    
}

