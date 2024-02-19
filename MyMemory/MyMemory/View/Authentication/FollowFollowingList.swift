//
//  FollowFollowingList.swift
//  MyMemory
//
//  Created by 정정욱 on 2/19/24.
//

import SwiftUI
import Kingfisher

struct FollowFollowingList: View {
    
    @ObservedObject var authViewModel: AuthService
    
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            List {
                ForEach(authViewModel.followingUserList, id: \.id) { user in
                    HStack{
                        if let imageUrl = user.profilePicture, let url = URL(string: imageUrl) {
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .clipShape(.circle)
                                .frame(width: 45, height: 45)
                        } else {
                            Circle()
                                .frame(width: 76, height: 76)
                                .foregroundStyle(Color(hex: "d9d9d9"))
                        }
                        
                        Text(user.name)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.vertical)
                    }
                }
                //.onDelete(perform: delete)
                .onMove(perform: move)
                .listRowBackground(Color.blue)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("팔로잉")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("뒤로")
                        }
                    }
                    
                    
                }
               
                
            }
            
        }
        
    }
//    mutating func delete(indexSet: IndexSet) {
//        authViewModel.followingUserList.remove(atOffsets: indexSet)
//    }
    
    func move(indices: IndexSet, newOffset: Int) {
        authViewModel.followingUserList.move(fromOffsets: indices, toOffset: newOffset)
    }
}


//#Preview {
//    FollowFollowingList()
//}
