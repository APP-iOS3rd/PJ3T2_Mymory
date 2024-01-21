//
//  NavigationBar+Modifier.swift
//  MyMemory
//
//  Created by 김소혜 on 1/18/24.
//

import SwiftUI

struct CustomNavigationBarModifier<C, L, R>: ViewModifier where C : View, L : View, R: View {
 
    let centerView: (() -> C)?
    let leftView: (() -> L)?
    let rightView: (() -> R)?
    
    init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
         
            ZStack {
                HStack {
                    self.leftView?()
                    Spacer()
                    self.rightView?()
                }
                
                HStack {
                    Spacer()
                    self.centerView?()
                    Spacer()
                }
                .clipped()
            }
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
  
            .background(
                Color.white
                  .cornerRadius(40, corners: [.bottomLeft, .bottomRight])
            )  
         
            content
            Spacer()
               
        }
        .background(
            Color.lightGray
                .clipped()
        )
 
        .navigationBarHidden(true)
        
    }
    
}

struct NavigationBarModifier: ViewModifier {
    
    var backgroundColor: UIColor?
    var titleColor: UIColor?
    
    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 12)
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                Color(self.backgroundColor ?? .clear)
                    .frame(maxWidth: .infinity, maxHeight:0)
                    .edgesIgnoringSafeArea(.top)
                    
//                    .background (
//                        RoundSpecificCorners(corners: [.bottomRight, .bottomLeft], radius: 36 )
//                            .foregroundColor(.white)
//                            .frame(height: 36)
//                            .edgesIgnoringSafeArea(.all)
//
//                            
//                    )
                
                Spacer()
            }
        }
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
extension View {
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }
    
    func customNavigationBar<C, L, R>(
        centerView: @escaping (() -> C),
        leftView: @escaping (() -> L),
        rightView: @escaping (() -> R)
    ) -> some View where C:View, L: View, R: View {
        modifier(CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: rightView))
    }
    
    func customNavigationBar<V>(
        centerView: @escaping (() -> V)
    ) -> some View where V : View {
        modifier(
            CustomNavigationBarModifier(
                centerView: centerView,
                leftView: {
                    EmptyView()
                }, rightView: {
                    EmptyView()
                }
            )
            
        )
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}



struct RoundSpecificCorners: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
