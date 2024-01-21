//
//  ProfileEditViewModel.swift
//  MyMemory
//
//  Created by 이명섭 on 1/21/24.
//

import Foundation
import _PhotosUI_SwiftUI

class ProfileEditViewModel: ObservableObject {
    @Published var selectedImage: PhotosPickerItem? = nil
    @Published var selectedPhotoData: Data? = nil
    
    init() {
        
    }
}
