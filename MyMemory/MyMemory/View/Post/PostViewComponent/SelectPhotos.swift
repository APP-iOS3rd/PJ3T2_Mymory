import SwiftUI
import PhotosUI
import Photos

struct SelectPhotos: View {
   
    @Binding var memoSelectedImageData: [Data]
    @State var memoSelectedImageItems: [PhotosPickerItem] = []
    @State var selectImage: Bool = false
    @State var showPermissionAlert: Bool = false
    @State var selectedItemsCounts: Int = 0
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(spacing: 10){
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
            
                    if selectImage == true {
                        
                        
                        ForEach(memoSelectedImageData.indices, id: \.self) { index in
                            if let uiimage = UIImage(data: memoSelectedImageData[index]) {
                                Image(uiImage: uiimage)
                                    .resizable()
                                    //.scaledToFit()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                            }
                        }
                        
        
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                // 해당 뷰가 업로드 될때 권한 받기
                checkPhotoLibraryPermission()
            }

        }
        .onChange(of: memoSelectedImageItems) { newValue in
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
                            selectImage = true
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
            // 허가 된 경우
            
        } else {
            // 권한이 거부된 경우 또는 아직 결정되지 않은 경우
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.selectImage = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        }
    }
    
}

struct SelectPhotos_Previews: PreviewProvider {
    static var previews: some View {
        let memoSelectedImageData = Binding<[Data]>.constant([])
        return SelectPhotos(memoSelectedImageData: memoSelectedImageData)
    }
}
