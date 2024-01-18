//
//  MemoService.swift
//  MyMemory
//
//  Created by 정정욱 on 1/17/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

struct MemoService {
    static let shared = MemoService()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    // 이미지를 업로드하고 URL을 반환하는 함수
    private func uploadImage(imageData: Data) async throws -> String {
        let storageRef = storage.reference()
        let imageRef = storageRef.child("images/\(UUID().uuidString).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지 업로드
        let _ = try await imageRef.putData(imageData, metadata: metadata)
        
        // 업로드된 이미지의 URL 가져오기
        // 업로드된 이미지의 URL 가져오기를 몇 번 시도
          var downloadURL: URL
          for _ in 1...5 {
              do {
                  downloadURL = try await imageRef.downloadURL()
                  print("Image uploaded with URL: \(downloadURL.absoluteString)")
                  return downloadURL.absoluteString
              } catch {
                  print("Retrying to get download URL...")
                  try await Task.sleep(nanoseconds: 1_000_000_000) // 2초 대기
              }
          }
          throw URLError(.cannotFindHost) // 적절한 에러 처리 필요
    }
    
    // Memo 모델을 넘기자
    func uploadMemo(newMemo: PostMemoModel) async {
        var imageDownloadURLs: [String] = []
        
        // 이미지 데이터 배열을 반복하면서 각 이미지를 업로드하고 URL을 저장
          for imageData in newMemo.memoSelectedImageData {
              do {
                  let imageUrl = try await uploadImage(imageData: imageData)
                  imageDownloadURLs.append(imageUrl)
                  print("Image URL added: \(imageUrl)")
              } catch {
                  print("Error uploading image: \(error)")
              }
          }
        
        // Firestore에 메모와 이미지 URL을 저장
        do {
            let ref = try await db.collection("Memos").addDocument(data: [
                "uid": newMemo.id,
                "userCoordinateLatitude": newMemo.userCoordinateLatitude,
                "userCoordinateLongitude": newMemo.userCoordinateLongitude,
                "userAddress": newMemo.userAddress,
                "memoTitle": newMemo.memoTitle,
                "memoContents": newMemo.memoContents,
                "isPublic": newMemo.isPublic,
                "memoTagList": newMemo.memoTagList,
                "memoLikeCount": newMemo.memoLikeCount,
                "memoSelectedImageURLs": imageDownloadURLs,  // 이미지 URL 배열 저장
                "memoCreatedAt": newMemo.memoCreatedAt,
            ])
            print("Document added with ID: \(ref.documentID)")
        } catch {
            print("Error adding document: \(error)")
        }
    }
}
