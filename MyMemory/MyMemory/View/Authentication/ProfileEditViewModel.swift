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
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    let db = Firestore.firestore()
    let storage = Storage.storage()

    
    init() {}
    
    func fetchEditProfileImage(imageData: Data, uid: String) async {
        var imageURL: String = ""
        
        do {
            imageURL = try await uploadImage(imageData: imageData)
        } catch {
            print("이미지 불러오기 실패")
            return
        }
        
        let userRef = db.collection("users").document(uid)
        
        do {
            try await userRef.updateData([
                "profilePicture": imageURL
            ])
            editProfileImageOnUserDefaults(image: imageURL)
        } catch {
            print("프로필사진 업데이트 실패")
        }
    }
    
    func uploadImage(imageData: Data) async throws -> String {
        guard let image = UIImage(data: imageData) else {
            throw NSError(domain: "Invalid image data", code: 0, userInfo: nil)
        }
        
        guard let compressedImageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(domain: "Image compression failed.", code: 0, userInfo: nil)
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        let _ = try await imageRef.putData(compressedImageData, metadata: metaData)
        
        var downloadURL: URL
        for _ in 1...3 {
            do {
                downloadURL = try await imageRef.downloadURL()
                print("Image uploaded with URL: \(downloadURL.absoluteString)")
                return downloadURL.absoluteString
            } catch {
                print("Retrying to get download URL...")
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
            }
        }
        throw URLError(.cannotFindHost) // 적절한 에러 처리 필요    }
    }
    
    func editProfileImageOnUserDefaults(image: String) {
//        if let savedData = UserDefaults.standard.object(forKey: "userInfo") as? Data {
//            let decoder = JSONDecoder()
//            
//            if var userInfo = try? decoder.decode(UserInfo.self, from: savedData) {
//                userInfo.profilePicture = image
//                let encoder = JSONEncoder()
//                
//                if let encoded = try? encoder.encode(userInfo) {
//                    UserDefaults.standard.set(encoded, forKey: "userInfo")
//                    print("수정완료!")
//                }
//            }
//        }
    }
}
