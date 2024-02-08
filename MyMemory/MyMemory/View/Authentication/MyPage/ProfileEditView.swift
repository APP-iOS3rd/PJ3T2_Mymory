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
    @State var isShowingAlert = false
    @State var alertMessage = ""
    @Environment(\.dismiss) var dismiss
    var existingProfileImage: String?
    var uid: String // 여기가 사용자 프로필 변경 uid 값이 들어와야함
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
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
                
                PhotosPicker(selection: $viewModel.selectedImage, matching: .any(of: [.images, .not(.livePhotos)]) ,photoLibrary: .shared()) {
                    Circle()
                        .overlay {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(.black)
                                .font(.system(size: 22))
                        }
                        .frame(width: 46, height: 46)
                        .foregroundStyle(Color.init(hex: "939397"))
                    
                }
            }
            .onChange(of: viewModel.selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotoData = data
                    }
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("이름")
                        .font(.regular16)
                        .frame(minWidth: 60)
                    
                    Spacer()
                    
                    TextField("내 이름", text: $viewModel.name)
                        .font(.regular16)
                }
                .padding(.bottom, 0)
                
                Divider()
                    .padding(.top, 10)
            }
            .padding(.top, 52)
        }
        .padding(.horizontal, 16)
        .padding(.top, 34)
        .customNavigationBar(
            centerView: {
                Text("프로필 수정")
                    .font(.semibold16)
                    .foregroundStyle(Color.textColor)
            },
            leftView: {
                BackButton()
            },
            rightView: {
                Button {
                    Task {
                        let result = await viewModel.fetchEditProfile(uid: uid,
                                                                imageData: self.viewModel.selectedPhotoData,
                                                                name: self.viewModel.name)
                        
                        self.alertMessage = result
                        self.isShowingAlert = true
                    }
                } label: {
                    Text("저장")
                        .font(.semibold17)
                        .foregroundStyle(Color.textColor)
                }
                .disabled(viewModel.selectedPhotoData == nil && viewModel.name == viewModel.currentName)
                .alert(alertMessage, isPresented: $isShowingAlert) {
                    Button("확인", role: .cancel) {
                        if viewModel.isEditionSuccessd {
                            dismiss()
                        }
                    }
                }
            },
            backgroundColor: Color.bgColor
        )
    }
}
