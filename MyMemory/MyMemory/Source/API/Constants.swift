//
//  Constants.swift
//  MyMemory
//
//  Created by 김소혜 on 1/22/24.
//

 
import Firebase

let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_MEMOS = Firestore.firestore().collection("Memos")

// 좋아요 기능
let COLLECTION_USER_LIKES = Firestore.firestore().collection("User-likes") // 유저가 좋아요 누른 일기를 파악
let COLLECTION_MEMO_LIKES = Firestore.firestore().collection("Memo-likes") // 일기 입장에서 누가 좋아요 눌렀는지 파악

// 팔로우, 팔로잉 기능
let COLLECTION_USER_Followers = Firestore.firestore().collection("User-Followers")
let COLLECTION_USER_Following = Firestore.firestore().collection("User-Following")
