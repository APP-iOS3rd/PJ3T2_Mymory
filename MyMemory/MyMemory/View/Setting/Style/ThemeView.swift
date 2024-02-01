//
//  ThemeView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/31/24.
//

import SwiftUI
import Combine

struct Theme: Identifiable, Hashable {
    var id: Int
    var name: String
    var isSelected: Bool
    var isPremium: Bool
    var textColor: Color = .textColor
    var bgColor: Color = .bgColor
    
}

final class ThemeViewModel: ObservableObject {
    @Published var themeList: [Theme] = []
    
    init(){
        fetchModel()
    }
}

extension ThemeViewModel {
    public func fetchModel(){
        self.themeList = [
            Theme(id: 0, name: "SYSTEM", isSelected: true, isPremium: false),
            Theme(id: 1, name: "Light", isSelected: false, isPremium: false),
            Theme(id: 2, name: "Dark", isSelected: false, isPremium: false, textColor: .white, bgColor: .black),
            Theme(id: 3, name: "테마1", isSelected: false, isPremium: false, textColor: .red, bgColor: .lightBlue),
            Theme(id: 4, name: "테마2", isSelected: false, isPremium: true),
            Theme(id: 5, name: "테마3", isSelected: false, isPremium: true),
            Theme(id: 6, name: "테마4", isSelected: false, isPremium: true)
        ]
    }
    
    
    func changeTheme(selectedThemeId: Int){
        // Theme의 isSelected 를 바꿔야함.
        // 선택된 theme는 true 로 , 나머지 모든 theme의 isSelected는 false가 되야함.
        // 모든 테마를 순회하며 선택된 테마의 isSelected를 true로, 나머지는 false로 설정
        themeList = themeList.map { theme in
            var modifiedTheme = theme
            if theme.id == selectedThemeId {
                modifiedTheme.isSelected = true
            } else {
                modifiedTheme.isSelected = false
            }
            return modifiedTheme
        }
    }
}
 
 


struct ThemeView: View {
    
    @StateObject var viewModel: ThemeViewModel = .init()
       //화면을 그리드형식으로 꽉채워
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
           // .padding(24)
          
            
            
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
            backgroundColor: .white
        )
    }
}

#Preview {
    ThemeView()
}
