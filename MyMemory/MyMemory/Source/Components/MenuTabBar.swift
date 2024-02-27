//
//  MenuTabBar.swift
//  MyMemory
//
//  Created by 이명섭 on 2/1/24.
//

import SwiftUI

struct MenuTabModel {
    var index: Int
    var image: String
}
/// 탭 메뉴를 선택할 때 사용하는 컴포넌트입니다.
/// - Parameters:
///     - menus: MenuTabModel을 담는 배열입니다. MenuTabModel은 순서와 id의 역할을 하는 Int 타입의 index, 아이콘을 사용할 때 systemName이 되는 String타입의 image로 구성되어있습니다.
///     - fullWidth: 사용하는 View에서 사용될 MenuTabBar의 width입니다.
///     - spacing: 버튼과 버튼 사이의 간격입니다.
///     - horizontalInset: 버튼 옆에서 끝까지의 거리입니다. 예를 들어, |옆간격|버튼| spacing |버튼|옆간격| 인 경우 옆간격 * 2를 입력하시면 됩니다.
struct MenuTabBar: View {
    var menus: [MenuTabModel]
    @Binding var selectedIndex: Int
    @State private var barX: CGFloat = 0
    
    private let spacing: CGFloat  // 버튼과 버튼 사이의 간격
    private let buttonLeadings: [CGFloat]
    private let barWidth: CGFloat
    private let buttonWidth: CGFloat
    private let fullWidth: CGFloat
    private let horizontalInset: CGFloat // 버튼과 양 옆의 거리 |패딩|옆간격|버튼| spacing |버튼|옆간격|패딩|
    
    init(
        menus: [MenuTabModel],
        selectedIndex: Binding<Int>,
        fullWidth: CGFloat,
        spacing: CGFloat,
        horizontalInset: CGFloat
    ) {
        self._selectedIndex = selectedIndex
        self.menus = menus
        // |옆간격|버튼| 패딩 |버튼|옆간격|
        // 전체크기 = (버튼*2) + 패딩 + 양옆 간격
        self.horizontalInset = horizontalInset
        self.fullWidth = fullWidth - horizontalInset
        self.spacing = spacing
        
        // 버튼 2개일때: 전체 간격 - (spacing * 1)
        // 버튼 3개일때: 전체 간격 - (spacing * 2)
        self.buttonWidth = (self.fullWidth - (spacing * CGFloat(menus.count - 1))) / CGFloat(menus.count)
        self.barWidth = buttonWidth
        
        var leadings = [CGFloat](repeating: 0, count: menus.count)
        for i in 0..<menus.count {
            let leading = (barWidth+spacing) * CGFloat(i)
            leadings[i] = leading
        }
        self.buttonLeadings = leadings
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: spacing) {
                ForEach(self.menus, id: \.index) { menu in
                    Button {
                        self.selectedIndex = menu.index
                    } label: {
                        VStack {
                            // 선택한 아이콘인 경우 fill로 변환
                            if menu.index == selectedIndex {
                                if menu.image == "rectangle.grid.1x2.fill" {
                                    Image(systemName: "\(menu.image)")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.accentColor)
                                } else {
                                    Image(systemName: "\(menu.image).fill")
                                        .font(.system(size: 20))
                                }
                            } else {
                                Image(systemName: menu.image)
                                    .font(.system(size: 20))
                                    .foregroundStyle(Color.init(hex: "898A8D"))
                            }
                            
                        }
                        .frame(maxWidth: buttonWidth)
                    }
                }
            }
            .frame(width: fullWidth, height: 32)
            // 아이콘 하단의 선
            Rectangle()
                .frame(width: barWidth, height: 2)
                .foregroundStyle(Color.accentColor)
                .alignmentGuide(.leading) { $0[.leading] }
                .offset(.init(width: barX, height: 0))
     
        }
        .onChange(of: selectedIndex) { _, index in
            withAnimation {
                barX = buttonLeadings[index]
            }
        }
        .frame(maxWidth: .infinity)
        .border(width: 1, edges: [.bottom], color: .borderColor)
        .background(Color.bgColor)
//        .overlay {
//            ZStack {
//                Spacer()
//                Rectangle()
//                    .frame(width: UIScreen.main.bounds.width, height: 1)
//                    .foregroundStyle(Color.init(hex: "#D9D9D9"))
//                    .padding(.top, 0)
//            }
//            
//        }
    }
}
