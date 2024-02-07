
import SwiftUI
import PhotosUI
import Photos

struct SelectPhotos: View {
   
    @Binding var isEdit: Bool
    @Binding var memoSelectedImageData: [Data]
    @Binding var selectedItemsCounts: Int 
    @State var memoSelectedImageItems: [PhotosPickerItem] = []
    @State var showPermissionAlert: Bool = false
  
    /*
     수정 모드일때 이미지 uid 저장 되는지 확인
     수정 이미지 누르면 일단 기존 이미지는 다 스토리지에서 삭제 하도록
     */
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    PhotosPicker(
                        selection: $memoSelectedImageItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(Color(.systemGray4))
                                .frame(width: 90, height: 90)
                            VStack(spacing: 0){
                                Spacer()
                                Image(systemName:"camera")
                                    .frame(width: 40, height: 30)
                                    .foregroundColor(.gray)
                                HStack(spacing: 0){
                                    Text("\(selectedItemsCounts)")
                                        .foregroundColor(.orange)
                                    Text("/5")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    
                    ForEach(memoSelectedImageData.indices, id: \.self) {
                        index in
                        if let uiImage = UIImage(data: memoSelectedImageData[index]) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .frame(width: 90, height: 90)
                                    .scaledToFill()
                                    .overlay {
                                        Button{
                                            memoSelectedImageData.remove(at: index)
                                            if !memoSelectedImageItems.isEmpty{
                                                memoSelectedImageItems.remove(at: index)
                                            }
                                                
                                        }label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                        }.offset(x: 35, y: -35)
                                    }

                        } else {
                           
                        }
                    }

                }
            }
            .onAppear {
                // 해당 뷰가 업로드 될 때 권한 받기
                checkPhotoLibraryPermission()
                
                if isEdit {
                    // 수정 모드일 때 기존 이미지 데이터 설정
                    selectedItemsCounts = memoSelectedImageData.count
                }
            }
        }
        .onChange(of: memoSelectedImageItems) { newValue in
            // 이미지 아이템이 변경되었을 때의 로직
            DispatchQueue.main.async {
                memoSelectedImageData.removeAll()
                selectedItemsCounts = 0 
            }
            for (index, item) in memoSelectedImageItems.enumerated() {
                item.loadTransferable(type: Data.self) { result in
                    switch result {
                    case .success(let data):
                        DispatchQueue.main.async {
                            memoSelectedImageData.append(data!)
                            print("사진 \(index+1) 업로드 완료, \(data)")
                            selectedItemsCounts += 1
                        }
                        
                    case .failure(let failure):
                        print("에러")
                        fatalError("\(failure)")
                    }
                }
            }
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            // 허가된 경우
        } else {
            // 권한이 거부된 경우 또는 아직 결정되지 않은 경우
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        // 권한 허가된 경우
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        }
    }
}
