//
//  CommunityTabView.swift
//  MyMemory
//
//  Created by 김소혜 on 2/23/24.
//

import SwiftUI

struct CommunityTabView: View {
    
    @Binding var selected: Int
    @State var presentLoginAlert: Bool = false
    let unAuthorized: (Bool) -> ()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
           Color.bgColor.ignoresSafeArea()
            
            CommunityView() { unauth in
                if unauth {
                    presentLoginAlert.toggle()
                }
            }
        }
        .moahAlert(isPresented: $presentLoginAlert) {
            MoahAlertView(message: "로그인 후에 사용 가능한 기능입니다.\n로그인 하시겠습니까?",
                          firstBtn: MoahAlertButtonView(type: .CUSTOM(msg: "둘러보기", color: .accentColor), isPresented: $presentLoginAlert, action: {
            }),
                          secondBtn: MoahAlertButtonView(type: .CUSTOM(msg: "로그인 하기"), isPresented: $presentLoginAlert, action: {
                self.dismiss()
                
                unAuthorized(true)
            })
            )
        }
    }
}

 
