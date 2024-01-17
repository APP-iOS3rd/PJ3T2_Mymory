//
//  ProfileEditView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ProfileEditView: View {
    @Binding var profileImage: PhotosPickerItem?
    @Binding var selectedPhotoData: Data?
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $profileImage, matching: .any(of: [.images, .not(.livePhotos)]) ,photoLibrary: .shared()) {
                if let selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(.circle)
                        .frame(width: 300, height: 300)
                } else {
                    Circle()
                        .frame(width: 300, height: 300)
                }
            }
            .onChange(of: profileImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                    }
                }
            }
            
            Button("수정하기") {
                print("수정하기")
            }
            .buttonStyle(Pill.standard)
            .padding(.top, 30)
            
            
        }
        .padding(.horizontal, 16)
    }
}
