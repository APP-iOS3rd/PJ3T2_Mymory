//
//  RegisterViewModel.swift
//  MyMemory
//
//  Created by hyunseo on 1/15/24.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI
import SafariServices
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class RegisterViewModel: ObservableObject {

    
    struct SafariView: UIViewControllerRepresentable {

        let url: URL

        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        }
    }
}
