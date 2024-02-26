//
//  UIApplication+Extesions.swift
//  MyMemory
//
//  Created by 김성엽 on 2/16/24.
//

import Foundation
import SwiftUI

// 화면 터치 시 키보드 내리기
extension UIApplication {
  func hideKeyboard() {
    guard let scene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
    let tapRecognizer = UITapGestureRecognizer(target: scene.windows.first, action: #selector(UIView.endEditing))
    tapRecognizer.cancelsTouchesInView = false
    tapRecognizer.delegate = self
    scene.windows.first?.addGestureRecognizer(tapRecognizer)
  }
}
 
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
