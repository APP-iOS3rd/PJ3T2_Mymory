//
//  Constants.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

 
import Firebase

let db: Firestore = {
    let settings = FirestoreSettings()

    // Use memory-only cache
    settings.cacheSettings =
    MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())

    // Use persistent disk cache, with 100 MB cache size
    settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)

    // Any additional options
    // ...

    // Enable offline data persistence
    let db = Firestore.firestore()
    db.settings = settings
    return db
}()
let COLLECTION_USERS = db.collection("users")
let COLLECTION_MEMOS = db.collection("Memos")

// 좋아요 기능
let COLLECTION_USER_LIKES = db.collection("User-likes") // 유저가 좋아요 누른 일기를 파악
let COLLECTION_MEMO_LIKES = db.collection("Memo-likes") // 일기 입장에서 누가 좋아요 눌렀는지 파악

// 팔로우, 팔로잉 기능
let COLLECTION_USER_Followers = db.collection("User-Followers")
let COLLECTION_USER_Following = db.collection("User-Following")

// 신고하기 기능
let COLLECTION_MEMO_REPORT = db.collection("Memo-Report")

// 값 세팅
let COLLECTION_SETTING_VALUE = db.collection("Setting-Values")
// Tag
let COLLECTION_TAG = db.collection("TagCount")
