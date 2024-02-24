//
//  FontView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/2/24.
//

import SwiftUI

struct FontView: View {
    
    @ObservedObject var fontManager: FontManager = .shared
    
    @Binding var currentFont: FontType //= FontManager.shared.userFontPreference ?? .Regular
     
    
    var body: some View {

        VStack {
            
            VStack {
                VStack(alignment: .leading, spacing: 10){
                    
                    Text("Font 미리보기")
                        .font(.userMainTextFont(fontType: currentFont, baseSize: 20))
                    
                    Text("폰트는 메모 상세보기 및 글씨 작성 부분에만 글씨에만 적용됩니다.")
                        .font(.userMainTextFont(fontType: currentFont, baseSize: 16))

                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .frame(width: 300, height: 150)
                .foregroundColor(.black)
                .background(Color.white)
                
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

            
            VStack {
            
                HStack {
                    
                    Text("프리텐다드")
                        .font(.medium16)
                        .bold()
                        .foregroundStyle(Color.textColor)
                    
                    Spacer()
                    
                    
                    Toggle("", isOn: Binding<Bool>(
                          get: {
                              currentFont == .Regular
                          },
                          set: { _ in
                              currentFont = .Regular
                             // fontManager.saveFontPreference(fontType: .Medium)
                              fontManager.setFont(fontData: .Regular)
                              print("폰트 변경:Pretendard")
                          }
                      ))
                    
                    .toggleStyle(.checkmark)
                  
                   
                }
                .padding(12)
         
                Divider()
                
                HStack {
                    
                    Text("영덕대게체")
                        .font(Font.custom("Yeongdeok Sea", size: 21 ))
                        .bold()
                        .foregroundStyle(Color.textColor)
                    
                    Spacer()
                    Toggle("", isOn: Binding<Bool>(
                          get: {
                              currentFont == .YeongdeokSea
                          },
                          set: { _ in
                              currentFont = .YeongdeokSea
                             // fontManager.saveFontPreference(fontType: .YeongdeokSea)
                              fontManager.setFont(fontData: FontType.YeongdeokSea)
                              print("폰트 변경: 영덕대게")
                          }
                      ))
                    .toggleStyle(.checkmark)
 
                   
                }
                .padding(12)
         
                Divider()
                
                HStack {
                    
                    Text("Neo둥근모체")
                        .font(Font.custom("NeoDunggeunmo-Regular", size: 18 ))
                        .bold()
                        .foregroundStyle(Color.textColor)
                    
                    Spacer()
                    
                 
                    
                    Toggle("", isOn: Binding<Bool>(
                          get: {
                              currentFont == .NeoDunggeunmo
                          },
                          set: { _ in
                              currentFont = .NeoDunggeunmo
                            //  fontManager.saveFontPreference(fontType: .NeoDunggeunmo)
                              fontManager.setFont(fontData: FontType.NeoDunggeunmo)
                              print("폰트 변경: 둥근모")
                          }
                      ))
                    .toggleStyle(.checkmark)
//                    .onChange(of: currentFont) {
//                       // fontManager.saveFontPreference(fontType: .NeoDunggeunmo)
//                    }

                }
                .padding(12)
                
                       
                Divider()
                
                HStack {
                    
                    Text("온글잎 의연체")
                        .font(Font.custom("OwnglyphEuiyeonChae", size: 26))
                        .bold()
                        .foregroundStyle(Color.textColor)
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding<Bool>(
                          get: {
                              currentFont == .OwnglyphEuiyeon
                          },
                          set: { _ in
                              currentFont = .OwnglyphEuiyeon
                            //  fontManager.saveFontPreference(fontType: .OwnglyphEuiyeon)
                              fontManager.setFont(fontData: FontType.OwnglyphEuiyeon)
                              print("폰트 변경: 온글잎 의연체")
                          }
                      ))
                    .toggleStyle(.checkmark)
                 
                }
                .padding(12)
         
            } // list
          //  .listStyle(.plain)
         
        }
        .customNavigationBar(
            centerView: {
                Text("폰트 선택")
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
 

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
 
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2)
                .frame(width: 25, height: 25)
                .cornerRadius(5.0)
                .overlay {
                    Image(systemName: configuration.isOn ? "checkmark" : "")
                }
                .onTapGesture {
                    withAnimation(.spring()) {
                        configuration.isOn.toggle()
                    }
                }
 
            configuration.label
 
        }
    }
}
 
 
extension ToggleStyle where Self == CheckboxToggleStyle {
 
    static var checkmark: CheckboxToggleStyle { CheckboxToggleStyle() }
}
 
