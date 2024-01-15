//
//  LoginViewModel.swift
//  MyMemory
//
//  Created by 김성엽 on 1/15/24.
//

import SwiftUI


// MARK: - 커스텀 텍스트필드
struct UnderLineTextfieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        
        VStack {
            // 텍스트필드
            configuration
                .frame(width: 350)
                
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray)
        }
    }
}



// MARK: - 커스텀 버튼
struct LoginButton: ButtonStyle {
    var labelColor = Color.white
    var backgroundColor = Color.gray

    
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
          .padding()
      .foregroundColor(labelColor)
      .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .frame(width: 350, height: 50)
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
        RoundedRectangle(cornerRadius: 10)
            .fill(backgroundColor)
            .frame(width: 350, height: 50)
      )
  }
}
