//
//  SceneDelegate.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import Foundation
import UIKit
import SwiftUI
                             
class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        if let windowScene = scene as? UIWindowScene {
               let window = UIWindow(windowScene: windowScene)
               window.rootViewController = UIHostingController(rootView: MainView(viewRouter: ViewRouter()))
               self.window = window
               window.makeKeyAndVisible()
           }
  
    }

    func sceneDidDisconnect(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
      
    }

    func sceneWillResignActive(_ scene: UIScene) {
      
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
      
    }

}
