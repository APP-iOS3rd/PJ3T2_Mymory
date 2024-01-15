//
//  SettingView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/7/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView() {
                VStack(alignment: .leading){
                    Text("일반")
                        .font(.bold20)
                        .padding(.top, 36)
                        .padding(.bottom, 32)
                    
                    VStack(spacing: 12) {
                        Group {
                            SettingMenuCell(name: "로그인 정보", iconName: "lock")
                            Divider()
                                .padding(.bottom, 20)
                            SettingMenuCell(name: "알림", iconName: "bell")
                            Divider()
                        }
                    }.padding(.horizontal, 9)
                    
                    Text("앱 정보")
                        .font(.bold20)
                        .padding(.bottom, 32)
                        .padding(.top, 58)
                    
                    VStack(spacing: 12) {
                        Group {
                            SettingMenuCell(name: "개인정보 처리방침", iconName: "book")
                            Divider()
                                .padding(.bottom, 20)
                            SettingMenuCell(name: "오픈소스 라이센스", iconName: "person.text.rectangle")
                            Divider()
                                .padding(.bottom, 20)
                            SettingMenuCell(name: "앱 버전")
                            Divider()
                        }
                    }.padding(.horizontal, 9)
                }
            }
            
            VStack(alignment: .trailing) {
                Button {
                    // 구현 필요
                } label: {
                    Text("로그아웃")
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                NavigationLink {
                    WithdrawalView()
                } label: {
                    Text("회원 탈퇴하기")
                        .underline()
                        .foregroundStyle(Color(UIColor.systemGray))
                }
            }
        }.padding(.horizontal, 12)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.large)
    }
}
