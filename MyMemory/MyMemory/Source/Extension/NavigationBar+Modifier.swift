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
    let backgroundColor: Color?
    let naviColor: Color?
    
    @Environment(\.dismiss) var dismiss
    @State private var offset = CGSize.zero
    
    init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil, backgroundColor: Color? = .lightGray, naviColor: Color? = .deepGray) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
        self.backgroundColor = backgroundColor
        self.naviColor = naviColor
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
          //  .border(width: 1, edges: [.bottom], color: Color.borderColor)
            
            .background(
                naviColor
                  .ignoresSafeArea()
            )
           
          
            content
              
            Spacer()
               
        }
        .background(
            self.backgroundColor.ignoresSafeArea()
        )
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onChanged { gesture in
                    if gesture.startLocation.x < CGFloat(40.0) {
                        if gesture.translation.width > 0 {
                            offset = gesture.translation
                            if offset.width > 200.0 {
                                dismiss()
                            }
                        }
                    }
                    
                }
                .onEnded { value in
                    withAnimation {
                        offset = CGSize.zero
                    }
                }
        )
        .navigationBarHidden(true)
        
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
    func customNavigationBar<C, L, R>(
        centerView: @escaping (() -> C),
        leftView: @escaping (() -> L),
        rightView: @escaping (() -> R),
        backgroundColor: Color?,
        naviColor: Color? = .bgColor3
    ) -> some View where C:View, L: View, R: View {
        modifier(CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: rightView, backgroundColor: backgroundColor, naviColor: naviColor))
    }
    
    func customNavigationBar<V>(
        centerView: @escaping (() -> V),
        backgroundColor: Color?,
        naviColor: Color? = .bgColor3
    ) -> some View where V : View {
        modifier(
            CustomNavigationBarModifier(
                centerView: centerView,
                leftView: {
                    EmptyView()
                }, 
                rightView: {
                    EmptyView()
                },
                backgroundColor: backgroundColor,
                naviColor: naviColor
            )
            
            
        )
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
     
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
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
