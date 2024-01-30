//
//  AlertView.swift
//  MyMemory
//
//  Created by 김성엽 on 1/29/24.
//

import SwiftUI

// MARK: - AlertView
public struct MoahAlertView: View {
    
    // 타이틀
    public var title: String?
    public var image: Image?
    // 내용
    public var message: String?
    //버튼
    public var firstBtn: MoahAlertButtonView
    // 취소버튼
    public var secondBtn: MoahAlertButtonView?
    
    public var body: some View {
        ZStack {
            // 배경
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                
                VStack(spacing: .zero) {
                    // 타이틀
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } else if let title = title{
                        Text(title)
                            .font(.bold16)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 내용
                    if let message = message {
                        Text(message)
                            .font(.regular16)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 5)
                    }
 
                    
                }
                .frame(height: 99)
                
                Rectangle()
                    .frame(width: 300, height: 1)
                    .foregroundColor(.lightGray)
                
                
                // 버튼
                HStack(spacing: 0) {
                    self.firstBtn
                    
                    if let second = secondBtn {
                        Rectangle()
                            .foregroundColor(.lightGray)
                            .frame(width: 1, height: 50)
                        second
                    }
                }
                .frame(height: 50)
            }
            .frame(width: 300, height: 150)
            .background(Color.white)
            .cornerRadius(8)
        }
        //.background(ClearBackground())
    }
}


// MARK: - Modifier
public struct MoahAlertModifier: ViewModifier {
    
    @Binding var isPresent: Bool
    
    let alert: MoahAlertView
    
    public func body(content: Content) -> some View {
            content
            .overlay {
                if isPresent {
                    alert
                }
            }
//                .fullScreenCover(isPresented: $isPresent) {
//                    // 모달 효과
//                    alert
//        }
    }
}

// MARK: - View Extension
extension View {
    public func moahAlert(isPresented:Binding<Bool>, moahAlert: @escaping () -> MoahAlertView) -> some View {
        return modifier(MoahAlertModifier(isPresent: isPresented, alert: moahAlert()))
    }
}


//// MARK: - 얼럿에서 투명한 배경
//public struct ClearBackground: UIViewRepresentable {
//    
//    public func makeUIView(context: Context) -> UIView {
//        
//        let view = ClearBackgroundView()
//        DispatchQueue.main.async {
//            view.superview?.superview?.backgroundColor = .clear
//        }
//        return view
//    }
//
//    public func updateUIView(_ uiView: UIView, context: Context) {}
//}
//
//open class ClearBackgroundView: UIView {
//    open override func layoutSubviews() {
//        guard let parentView = superview?.superview else {
//            print("ERROR: Failed to get parent view to make it clear")
//            return
//        }
//        parentView.backgroundColor = .clear
//    }
//}
