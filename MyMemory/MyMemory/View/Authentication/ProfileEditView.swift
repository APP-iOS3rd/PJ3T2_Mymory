//
//  ProfileEditView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/16/24.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct ProfileEditView: View {
    @StateObject var viewModel: ProfileEditViewModel = .init()
    var existingProfileImage: String?
    var uid: String
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $viewModel.selectedImage, matching: .any(of: [.images, .not(.livePhotos)]) ,photoLibrary: .shared()) {
                if let selectedPhotoData = viewModel.selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(.circle)
                        .frame(width: 300, height: 300)
                } else {
                    if let imageUrl = existingProfileImage, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(.circle)
                        } placeholder: {
                            ProgressView()
                        }.frame(width: 300, height: 300)
                    } else {
                        Circle()
                            .frame(width: 300, height: 300)
                    }
                }
            }
            .onChange(of: viewModel.selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotoData = data
                    }
                }
            }
            
            Button("수정하기") {
                if let photoData = viewModel.selectedPhotoData {
                    Task {
                        await viewModel.fetchEditProfileImage(
                            imageData: photoData,
                            uid: uid
                        )
                    }
                }
            }
            .disabled(viewModel.selectedPhotoData == nil)
            .buttonStyle(Pill.standard)
            .padding(.top, 30)
            
            
        }
        .padding(.horizontal, 16)
        .customNavigationBar(
            centerView: {
                Text("프로필 편집")
            },
            leftView: {
                BackButton()
            },
            rightView: {
                EmptyView()
            },
            backgroundColor: Color.bgColor
        )
    }
}
