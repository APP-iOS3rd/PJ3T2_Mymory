//
//  WithdrawalView.swift
//  MyMemory
//
//  Created by 이명섭 on 1/8/24.
//

import SwiftUI

struct WithdrawalView: View {
    @EnvironmentObject var viewModel: SettingViewModel
    @Environment(\.presentationMode) private var presentationMode
    @Binding var isCurrentUserLoginState: Bool
    @Binding var user: User?
    
    // 추가: @State 변수를 사용하여 memoCount와 imageCount를 업데이트
    @State private var memoCount: Int = 0
    @State private var imageCount: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                
                Text("지금 회원탈퇴를 하시면")
                    .font(.bold24)
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("﹒  \(memoCount)개의 메모")
                                .font(.regular24)
                            Spacer()
                        }
                        Text("﹒  \(imageCount)개의 사진")
                            .font(.regular24)
                        Text("﹒  구매한 폰트, 마커, 메모지")
                            .font(.regular24)
                    }
                }
                .padding(EdgeInsets(top: 27, leading: 16, bottom: 27, trailing: 16))
                .background(Color.bgColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onAppear {
                    Task {
                        do {
                            let counts = try await AuthService.shared.countUserData(uid: user?.id ?? "")
                            DispatchQueue.main.async {
                                memoCount = counts.0
                                imageCount = counts.1
                            }
                        } catch {
                            print("Error: \(error)")
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("회원님의 소중한 추억들이 사라집니다.")
                        .font(.bold24)
                    Text("그래도 회원을 탈퇴하시겠어요?")
                        .font(.regular24)
                }
                .padding(.top, 22)
                .padding(.bottom, 32)
                
                Spacer()
                
                VStack {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("그대로 사용할게요")
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .background(.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        Task {
                          await MemoService.shared.removeUserAllData(uid: user?.id ?? "")
                          isCurrentUserLoginState = false
                          viewModel.isShowingWithdrawalAlert = true
                          viewModel.fetchUserLogout {
                            
                          }
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
                            // 앱 종료 코드 추가
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                exit(0)
                            }
                            //self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(user?.id == nil)
                }
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height)
            .padding(.horizontal, 16)
        }
        .customNavigationBar(centerView: {
            Text("회원 탈퇴")
        }, leftView: {
            BackButton()
        }, rightView: {
            EmptyView()
        }, backgroundColor: .bgColor3)
    }
}
