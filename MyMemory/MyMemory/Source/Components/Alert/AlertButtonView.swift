//
//  AlertButtonView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/29/24.
//

import SwiftUI

// MARK: - AlertButtonType
public enum MoahAlertButtonType {
    case CONFIRM
    case CANCEL
    case SETTING
    case CUSTOM(msg: String, color: Color = .blue)
}

// MARK: - AlertButtonView
public struct MoahAlertButtonView: View {
    
    public typealias Action = () -> Void
    
    @Binding public var isPresented: Bool
    // 텍스트
    public var btnTitle: String = "확인"
    // 배경색
    public var btnColor: Color = .blue
    // 전달받은 액션
    public var action: Action
    // Alert 타입
    public var type : MoahAlertButtonType
    
    public init(type: MoahAlertButtonType,
                isPresented: Binding<Bool>,
                action: @escaping Action) {
        self._isPresented = isPresented
        
        switch type {
        case .CONFIRM:
            self.btnTitle = "확인"
            self.btnColor = .blue
        case .CANCEL:
            self.btnTitle = "취소"
            self.btnColor = .red
        case .SETTING:
            self.btnTitle = "설정"
            self.btnColor = .blue
        case .CUSTOM(msg: let msg, color: let color) :
            self.btnTitle = msg
            self.btnColor = color
        }
        self.action = action
        self.type = type
    }
    
    public var body: some View {
        Button {
            // 얼럿 닫아주기
            self.isPresented = false
            
            // 전달받은 액션 추가
            action()
        } label: {
            Text(btnTitle)
                .foregroundColor(self.btnColor)
                .font(.regular18)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
