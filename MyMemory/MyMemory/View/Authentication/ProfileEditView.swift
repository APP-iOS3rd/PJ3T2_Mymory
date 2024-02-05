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
                        .frame(width: 160, height: 160)
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
                        }.frame(width: 160, height: 160)
                    } else {
                        Circle()
                            .frame(width: 160, height: 160)
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
            .overlay(
                ZStack {
                    Circle()
                        .foregroundStyle(Color.textGray)
                        .frame(width: 46, height: 46)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28)
                }.offset(CGSize(width: 50, height: 50))
            )
            VStack {
                HStack {
                    Text("이름")
                    TextField("이름을 입력하세요", text: $viewModel.name)
                }
             Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 0.5)
                    .foregroundStyle(Color.textGray)
            }.padding(.top, 30)
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

            Spacer()
            
        }
        .padding(.horizontal, 16)
        .overlay(content: {
            if viewModel.isLoading {
                LoadingView()
            }
        })
    }
}
#Preview {
    ProfileEditView(uid: "ra")
}
