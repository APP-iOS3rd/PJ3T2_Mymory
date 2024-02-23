//
//  ThemeView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/31/24.
//

import SwiftUI

struct ThemeView: View {
    
    @ObservedObject var themeManager: ThemeManager = .shared
    // 화면을 그리드 형식으로 꽉채워 준다.
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        
        VStack {
            
            VStack {
                
                
                VStack(alignment: .leading, spacing: 10){
                    Text("테마설정")
                        .font(.bold20)
                    Text("시스템모드에 따라 변경됨.")
                        .font(.medium16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
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
             
                    ForEach(themeManager.systemThemeList, id: \.self) { theme in
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
                                themeManager.changeTheme(to: theme)
                            }

                       
                            Button {
                                themeManager.changeTheme(to: theme)
                             // viewModel.changeTheme(selectedThemeId: theme.id)
                            } label: {
                                Text(theme.rawValue)
                            }
                            .buttonStyle(themeManager.isThemeSelected(theme) ? Pill.deepGray : Pill.standard3)
                            // .foregroundColor(themeManager.isThemeSelected(theme) ? theme.textColor : .gray)
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
