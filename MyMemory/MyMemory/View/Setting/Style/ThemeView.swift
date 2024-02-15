//
//  ThemeView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/31/24.
//

import SwiftUI

struct ThemeView: View {
    
    @ObservedObject var themeManager: ThemeManager = .shared
    @State var currentTheme: ThemeType = ThemeManager.shared.userThemePreference ?? .system
    
    // 화면을 그리드 형식으로 꽉채워 준다.
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        
        VStack {
            
            VStack {
                
                
                VStack(alignment: .leading, spacing: 10){
                    Text("메모지 컬러 변경")
                        .font(.bold20)
                    Text("기본 메모지 선택 설정을 변경할 수 있습니다.")
                        .font(.medium16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(themeManager.loadThemePreference().bgColor)
                .foregroundColor(themeManager.loadThemePreference().textColor)
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
             
                    ForEach(themeManager.themeList, id: \.self) { theme in
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
                                //viewModel.changeTheme(selectedThemeId: theme.id)
                            }

                       
                            Button {
                                themeManager.changeTheme(to: theme)
                              //  viewModel.changeTheme(selectedThemeId: theme.id)
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
                Text("메모지 선택")
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
