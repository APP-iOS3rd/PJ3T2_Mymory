//
//  UserStatusCell.swift
//  MyMemory
//
//  Created by 김소혜 on 2/5/24.
//

import SwiftUI

struct UserStatusCell: View {
    
    @ObservedObject var authViewModel: AuthViewModel = .shared
    
    var body: some View {
        HStack {
            VStack{
                Text("0")
                Text("메모")
            }
            
            
            
            VStack{
                Text("\(authViewModel.followerCount)")
                Text("팔로워")
            }
            
            
            VStack{
                Text("\(authViewModel.followingCount)")
                Text("팔로잉")
            }
            
            .padding(.leading, 10)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    UserStatusCell()
}
