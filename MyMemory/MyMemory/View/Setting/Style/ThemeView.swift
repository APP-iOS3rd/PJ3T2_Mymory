//
//  ThemeView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/31/24.
//

import SwiftUI

struct ThemeView: View {
    
    @StateObject var viewModel: ThemeViewModel = .init()

    // 화면을 그리드 형식으로 꽉채워 준다.
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        
        VStack {
            
            VStack {
                VStack(alignment: .leading, spacing: 10){
                    Text("Solarized Light")
                        .font(.bold20)
                       // .foregroundStyle(Color.)
                    Text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. ")
                        .font(.medium16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(Color.lightBlue)
                
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                    
                        .stroke(Color.deepGray)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
            
            .frame(maxWidth: .infinity)
            .background(Color.lightGray)
            
        
            
            ScrollView {
                
                LazyVGrid(columns: columns, spacing: 20) {
             
                    ForEach(viewModel.themeList) { theme in
                        VStack  {
                            VStack {
                                Text("31")
                                    .foregroundStyle(theme.textColor)
                            }
                            .frame(width: 60, height: 60)
                            .background(theme.bgColor)
                            
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.darkGray)
                            )
                            .onTapGesture {
                                viewModel.changeTheme(selectedThemeId: theme.id)
                            }

                           
                            Button {
                                viewModel.changeTheme(selectedThemeId: theme.id)
                            } label: {
                                Text(theme.name)
                            }
                            .buttonStyle(theme.isSelected ? Pill.deepGray : Pill.standard3)
                                
                        }
                        .padding()
                        
                    }
                }
            }
        }
        .customNavigationBar(
            centerView: {
                Text("테마 선택")
            },
            leftView: {
                BackButton()
            },
            rightView: {
              EmptyView()
            },
            backgroundColor: .bgColor3
        )
    }
}

#Preview {
    ThemeView()
}
