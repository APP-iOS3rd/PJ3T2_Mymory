//
//  NavigationBar+Modifier.swift
//  MyMemory
//
//  Created by 김소혜 on 1/18/24.
//

import SwiftUI

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
                    .frame(maxWidth: .infinity, maxHeight: 0)
                    .edgesIgnoringSafeArea(.top)
                   
                    .background (
                        RoundSpecificCorners(corners: [.bottomRight, .bottomLeft], radius: 36 )
                            .foregroundColor(.white)
                            .frame(height: 36)
                            
                    )
                
                Spacer()
            }
        }
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
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
