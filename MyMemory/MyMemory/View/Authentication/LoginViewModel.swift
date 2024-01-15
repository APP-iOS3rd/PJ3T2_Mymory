//
//  LoginViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/15/24.
//

import SwiftUI


// MARK: - 커스텀 버튼
struct LoginButton: ButtonStyle {
    var labelColor = Color.white
    var backgroundColor = Color.gray

    
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .padding()
      .foregroundColor(labelColor)
      .background(
        RoundedRectangle(cornerRadius: 5)
            .fill(backgroundColor)
            .frame(width: 350, height: 40)
      )
  }
}


struct SocialLoginButton: ButtonStyle {
    var labelColor = Color.white
    var backgroundColor = Color.black

    
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .padding()
      .foregroundColor(labelColor)
      .background(
        RoundedRectangle(cornerRadius: 5)
            .fill(backgroundColor)
            .frame(width: 350, height: 40)
      )
  }
}
