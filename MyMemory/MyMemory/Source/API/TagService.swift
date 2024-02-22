//
//  TagService.swift
//  MyMemory
//
//  Created by 김태훈 on 2/21/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreLocation
import UIKit
struct TagCount: Identifiable, Codable {
    @DocumentID var id: String?
    var count: Int
}
final class TagService: ObservableObject{
    static let shared = TagService()
    let storage = Storage.storage()
    var tagList: [String] = []
    init() {
        Task {
            await loadTagList()
        }
    }
    @MainActor
    private func updateTagList(_ newValue: [String]) {
        if newValue.count < 15 {
            self.tagList = newValue.reversed()
        } else {
            self.tagList = Array(newValue.reversed()[0..<15])
        }
        
    }
    func addNewTag(_ newValue: String) async {
        do {
            var newTag = TagCount(id: newValue, count: 0)
            let current = try await COLLECTION_TAG.document(newValue).getDocument()
            if current.exists {
                if let tag = try? current.data(as: TagCount.self) {
                    newTag = TagCount(id:tag.id, count: tag.count + 1)
                }
            }
            if newTag.count == 0 {
                // 새로운 tag 업로드
                try await COLLECTION_TAG.document(newValue).setData(from: newTag)

            } else {
                //이미 있는 tag 업데이트
                try await COLLECTION_TAG.document(newValue).setData(from: newTag, merge: true)
            }
            await loadTagList()
        } catch {
            print("태그 추가에 실패했습니다: \(error.localizedDescription)")
        }
    }
    func deleteTag(_ tagStr: String) async {
        var newTag = TagCount(id: tagStr, count: 0)
        do {
            let tagCount = try await COLLECTION_TAG.document(tagStr).getDocument()
            if tagCount.exists {
                if let tag = try? tagCount.data(as: TagCount.self) {
                    if tag.count > 0 {
                        newTag = TagCount(id:tag.id, count: tag.count - 1)
                    }
                }

            }
            if newTag.count == 0 {
                // 새로운 tag 업로드
                try await COLLECTION_TAG.document(tagStr).setData(from: newTag)

            } else {
                //이미 있는 tag 업데이트
                try await COLLECTION_TAG.document(tagStr).setData(from: newTag, merge: true)
            }
            await loadTagList()

        } catch {
            print("태그 변경에 실패했습니다: \(error.localizedDescription)")
        }
    }
    private func loadTagList() async {
        do {
            let docs = try await COLLECTION_TAG
                .order(by: "count")
                .getDocuments()
            var tagList:[TagCount] = []
            for doc in docs.documents {
                guard let tag = try? doc.data(as: TagCount.self) else {return}
                tagList.append(tag)
            }
            let res: [String] = tagList.filter{$0.id != nil}.map{$0.id!}
            await updateTagList(res)
        } catch {
            print("태그 목록을 불러오는 데 실패했습니다: \(error.localizedDescription)")
        }
    }
}
