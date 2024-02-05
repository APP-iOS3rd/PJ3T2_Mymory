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
    @Environment(\.dismiss) var dismiss
    var existingProfileImage: String?
    var uid: String // 여기가 사용자 프로필 변경 uid 값이 들어와야함
    
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
            .onChange(of: viewModel.isEditionSuccessd) { newValue in
                if newValue {
                    dismiss()
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
        .overlay(content: {
            if viewModel.isLoading {
                LoadingView()
            }
        })
    }
}
