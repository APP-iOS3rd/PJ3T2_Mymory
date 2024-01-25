//
//  ImageUploader.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

import Foundation
import UIKit
import FirebaseStorage

// profile, Memo 타입에 따라 파일 경로 설정
enum UploadType {
    case profile
    case memo
    
    var filePath : StorageReference {
        let filename = NSUUID().uuidString // unique id 생성
        switch self {
        case .profile:
            return Storage.storage().reference(withPath: "/profile_images/\(filename)")
        case .memo:
            return Storage.storage().reference(withPath: "/memo_images/\(filename)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage,type: UploadType, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("DEBUG: failed to upload image \(error.localizedDescription)")
                return
            }
            
            
            ref.downloadURL { url , _ in
                guard let imageUrl = url?.absoluteString else { return } // 함수에서 String으로 전달받음.
                completion(imageUrl)
            }
        }
    }
}
