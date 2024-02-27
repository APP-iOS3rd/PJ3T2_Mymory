//
//  SettingMenuCell.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct SettingMenuCell: View {
    var name: String
    var page: String = ""
    
    var body: some View {
        
        NavigationLink {
            chooseDestination()
        } label: {
            HStack(alignment: .center) {
                Text(name)
                    .font(.medium14)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 17))
                    .opacity(0.3)
            }
            .foregroundStyle(Color.textColor)
        }

    }
    
    
    @ViewBuilder
    func chooseDestination() -> some View {
        switch page {
        case "theme": ThemeView()
        case "login": LoginView()
        case "loginInfo": ProfileEditView(isEdit: false, existingProfileImage: AuthService.shared.currentUser?.profilePicture)
       // case "font": FontView()
        case "termsOfUse": TermsView(kindOfTerms: .use)
        case "termsOfPrivacy": TermsView(kindOfTerms: .privacy)
        default: EmptyView()
        }
    }
}
