//
//  MemoThemeView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/15/24.
//

import SwiftUI

struct MemoThemeView: View {
    
    @ObservedObject var themeManager: ThemeManager = .shared
    @EnvironmentObject var viewModel: PostViewModel
    @Binding var currentTheme: ThemeType
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        
        VStack {
            
            VStack {
                
                
                VStack(alignment: .leading, spacing: 10){
                    Text("메모지 컬러 변경")
                        .font(.bold20)
                    Text("현재 글의 메모지 선택 설정을 변경할 수 있습니다.")
                        .font(.medium16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(currentTheme.bgColor)
                .foregroundColor(currentTheme.textColor)
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
             
                    ForEach(themeManager.themeList, id:\.self) { theme in
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
                                //themeManager.changeTheme(to: theme)
                                currentTheme = themeManager.setTheme(themeType: theme)
                            
                            }
                       
                            Button {
                                //themeManager.changeTheme(to: theme)
                                currentTheme = themeManager.setTheme(themeType: theme)
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
//                Button ("저장"){
//                    viewModel.memoTheme = themeManager.userThemePreference ?? .system
//                }
            },
            backgroundColor: .bgColor3
        )
    }
}
 
