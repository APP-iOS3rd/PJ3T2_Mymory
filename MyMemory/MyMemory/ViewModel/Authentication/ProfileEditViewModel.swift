//
//  ProfileEditViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/21/24.
//

import Foundation
import _PhotosUI_SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

class ProfileEditViewModel: ObservableObject {
    @Published var isEditionSuccessd = false
    @Published var isLoading: Bool = false
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    @Published var currentName: String = AuthService.shared.currentUser?.name ?? ""
    @Published var name: String = AuthService.shared.currentUser?.name ?? ""
    let storage = Storage.storage()
    
    init() {}
    
    func fetchEditProfileImage(imageData: Data, uid: String) async -> Result<Bool, ProfileEditErrorType> {
        isLoading = true
        var imageURL: String = ""
        let storageRef = storage.reference()
        do {
            let result = try await uploadImage(imageData: imageData)
            switch result {
            case .success(let success):
                imageURL = success
            case .failure(_):
                return .failure(.uploadUserProfileImage)
            }
        } catch {
            print("이미지 불러오기 실패")
            isLoading = false
            return .failure(.uploadUserProfileImage)
        }
        
        let userRef = COLLECTION_USERS.document(uid)
        let deleteProfileImageResult = await AuthService.shared.removeUserProfileImage(uid: uid)
        
        guard let _ = try? deleteProfileImageResult.get() else {
            return .failure(.deleteUserProfileImage)
        }
        
        do {
            try await userRef.updateData([
                "profilePicture": imageURL
            ])
            return .success(true)
        } catch {
            isLoading = false
            print("프로필사진 업데이트 실패 \(error)")
            return .failure(.updateProfileImage)
        }
    }
    
    func uploadImage(imageData: Data) async throws -> Result<String, ProfileEditErrorType> {
        guard let image = UIImage(data: imageData) else {
            return .failure(.invalidImageData)
        }
        
        guard let compressedImageData = image.jpegData(compressionQuality: 0.2) else {
            return .failure(.imageCompressionFail)
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(UUID().uuidString).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let _ = try await imageRef.putData(compressedImageData, metadata: metaData)
        
        var downloadURL: URL
        for _ in 1...3 {
            do {
                downloadURL = try await imageRef.downloadURL()
                print("Image uploaded with URL: \(downloadURL.absoluteString)")
                isLoading = false
                isEditionSuccessd = true
                return .success(downloadURL.absoluteString)
            } catch {
                print("Retrying to get download URL...")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
                isLoading = false
            }
        }
        return .failure(.uploadUserProfileImage)
    }
    
    func editUserName(changeName: String, uid: String) async -> Result<Bool, ProfileEditErrorType> {
        let userDocument = COLLECTION_USERS.document(uid)
        do {
            try await userDocument.updateData([
                "name": changeName
            ])
            return .success(true)
        } catch {
            return .failure(.changeUserName)
        }
    }
    
    func fetchEditProfile(uid: String, imageData: Data?, name: String) async -> String {
        self.isLoading = true
        if imageData != nil && self.name != AuthService.shared.currentUser?.name {
            let changeUserNameResult = await editUserName(changeName: name, uid: uid)
            switch changeUserNameResult {
            case .success(_):
                let changeImageResult = await fetchEditProfileImage(imageData: imageData!, uid: uid)
                switch changeImageResult {
                case .success(_):
                    self.isEditionSuccessd = true
                    self.isLoading = false
                    return "프로필 수정이 완료되었습니다."
                case .failure(let failure):
                    self.isLoading = false
                    return self.errorHandler(errorType: failure)
                }
            case .failure(let failure):
                self.isLoading = false
                return self.errorHandler(errorType: failure)
            }
        } else if let profileImage = imageData {
            let changeImageResult = await fetchEditProfileImage(imageData: profileImage, uid: uid)
            switch changeImageResult {
            case .success(_):
                self.isEditionSuccessd = true
                self.isLoading = false
                return "프로필 사진 변경이 완료되었습니다."
            case .failure(let failure):
                self.isLoading = false
                return self.errorHandler(errorType: failure)
            }
        } else {
            let changeUserNameResult = await editUserName(changeName: name, uid: uid)
            switch changeUserNameResult {
            case .success(_):
                self.isEditionSuccessd = true
                self.isLoading = false
                return "이름 변경이 완료되었습니다."
            case .failure(let failure):
                self.isLoading = false
                return errorHandler(errorType: failure)
            }
        }
        
    }
    
    private func errorHandler(errorType: ProfileEditErrorType) -> String {
        switch errorType {
        case .changeUserName:
            return "이름을 변경하는데 실패했습니다."
        case .uploadUserProfileImage:
            return "프로필 사진 업로드에 실패했습니다."
        case .updateProfileImage:
            return "프로필 사진 변경에 실패했습니다."
        case .deleteUserProfileImage:
            print("이전 프로필사진 삭제 실패")
            return "프로필 사진 변경에 실패했습니다."
        case .invalidImageData:
            return "올바른 형식의 이미지가 아닙니다."
        case .imageCompressionFail:
            print("이미지 압축 실패")
            return "프로필 사진 업데이트에 실패했습니다."
        }
    }
}
