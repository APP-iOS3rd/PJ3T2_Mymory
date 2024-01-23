//
//  WithdrawalView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct WithdrawalView: View {
    @EnvironmentObject var viewModel: SettingViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var isCurrentUserLoginState: Bool
    @Binding var user: User?
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text("지금 회원탈퇴를 하시면")
                        .font(.bold24)
                        .padding(.bottom, 53)
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("·  1,203,102개의 메모")
                                .font(.regular24)
                            Spacer()
                        }
                        Text("·  341개의 핫플레이스")
                            .font(.regular24)
                        Text("·  1,204,593장의 사진")
                            .font(.regular24)
                        Text("·  기타 등등")
                            .font(.regular24)
                    }
                }
                .padding(EdgeInsets(top: 36, leading: 16, bottom: 36, trailing: 16))
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    Text("이 모두 사라집니다!")
                        .font(.bold24)
                    Text("그래도 회원을 탈퇴하시겠어요?")
                        .font(.regular24)
                }
                .padding(.top, 22)
                .padding(.bottom, 32)
                
                Button {
                    dismiss()
                } label: {
                    Text("그대로 사용할게요")
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    viewModel.fetchUserWithdrawal(uid: user?.id ?? "") {
                        isCurrentUserLoginState = false
                        viewModel.isShowingWithdrawalAlert = true
                    }
                } label: {
                    Text("네 그래도 탈퇴할게요")
                        .foregroundStyle(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .alert("회원탈퇴되었습니다.", isPresented: $viewModel.isShowingWithdrawalAlert) {
                    Button("확인", role: .cancel) {
                        dismiss()
                    }
                }
                .disabled(user?.id == nil)
            }
            .navigationTitle("회원 탈퇴")
            .navigationBarTitleDisplayMode(.large)
            .padding(.top, 100)
            .padding(.horizontal, 16)
        }
    }
}
