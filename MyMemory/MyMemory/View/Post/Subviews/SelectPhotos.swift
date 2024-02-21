
import SwiftUI
import PhotosUI
import Photos

struct SelectPhotos: View {
    
    @Binding var isEdit: Bool
    @Binding var memoSelectedImageData: [String:Data]
    @Binding var selectedItemsCounts: Int
    @State var memoSelectedImageItems: [PHAsset] = []
    @State var showPermissionAlert: Bool = false
    @State private var isImageSelection: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showCamera: Bool = false
    @State private var showCountAlert = false
    
    @State var fromCamera: UIImage? = nil
    /*
     수정 모드일때 이미지 uid 저장 되는지 확인
     수정 이미지 누르면 일단 기존 이미지는 다 스토리지에서 삭제 하도록
     */
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Button{
                        self.isImageSelection.toggle()
                    } label: {
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
                    }.actionSheet(isPresented: $isImageSelection) {
                        ActionSheet(title: Text("사진을 선택하세요"), buttons: [
                            .default(Text("카메라")) {
                                print("카메라")
                                if self.selectedItemsCounts == 5 {
                                    self.showCountAlert = true
                                } else {
                                    self.showCamera = true
                                }
                            },
                            
                                .default(Text("사진 라이브러리")) {
                                    self.showPhotoPicker = true
                                    
                                },
                            .cancel()
                        ])
                    }.fullScreenCover(isPresented: $showPhotoPicker){
                        // 사진 선택 뷰를 표시합니다.
                        CustomPhotosPicker(selected: $memoSelectedImageItems)
                        
                        //                        PhotosPicker(selection: $memoSelectedImageItems,
                        //                            maxSelectionCount: 5,
                        //                            matching: .images
                        //                        ) { Text("사진")}
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        ImagePicker(image: $fromCamera, type: .camera)
                            .ignoresSafeArea()
                    }
                    ForEach(Array(memoSelectedImageData.keys), id: \.self) { key in
                        if let uiImage = UIImage(data: memoSelectedImageData[key]!) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 90, height: 90)
                                .scaledToFill()
                                .overlay {
                                    Button{
                                        memoSelectedImageData.removeValue(forKey: key)
                                        if !memoSelectedImageItems.isEmpty{
                                            memoSelectedImageItems.removeAll(where: {$0.localIdentifier == key})
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
                self.memoSelectedImageItems = []
                if isEdit {
                    // 수정 모드일 때 기존 이미지 데이터 설정
                    selectedItemsCounts = memoSelectedImageData.count
                }
            }
        }
        .onChange(of: self.fromCamera, { oldValue, newValue in
            if let data = newValue?.jpegData(compressionQuality: 1.0){
                let temp = UUID().uuidString
                self.memoSelectedImageData[temp] = data
//                self.selectedItemsCounts += 1
            }
        })
        .onChange(of: memoSelectedImageData, { oldValue, newValue in
            self.selectedItemsCounts = newValue.count
        })
        .onChange(of: memoSelectedImageItems) { oldValue,newValue in
            // 이미지 아이템이 변경되었을 때의 로직
            DispatchQueue.main.async {
                for val in oldValue {
                    memoSelectedImageData.removeValue(forKey: val.localIdentifier)
//                    selectedItemsCounts -= 1
                }
//                memoSelectedImageData.removeAll()
//                selectedItemsCounts = 0
            }
            for (index, item) in memoSelectedImageItems.enumerated() {
                Task {
                    if let image = await item.convertPHAssetToImage() {
                        DispatchQueue.main.async {
                            let data = image.0.jpegData(compressionQuality: 1.0)
                            
                            memoSelectedImageData[image.1] = data!
                            print("사진 \(index+1) 업로드 완료, \(data)")
//                            selectedItemsCounts += 1
                        }
                    } else {
                        
                    }
                }
            }
        }
        .moahAlert(isPresented: $showCountAlert) {
            MoahAlertView(title: "사진은 \(5)개 까지만\n선택 가능합니다!",firstBtn: .init(type: .CONFIRM, isPresented: $showCountAlert, action: {
                
            }))
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
