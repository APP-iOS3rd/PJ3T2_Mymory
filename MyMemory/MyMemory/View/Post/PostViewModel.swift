import Foundation
import CoreLocation
import _PhotosUI_SwiftUI

class PostViewModel: ObservableObject {
    @Published var memoData: [MemoModel] = []

    func saveMemo(userCoordinate: CLLocationCoordinate2D, memoTitle: String, memoContents: String, memoAddressText: String, memoSelectedImageItems: [PhotosPickerItem], memoSelectedTags: [String]) {
        let newMemo = MemoModel(userCoordinate: userCoordinate,
                                    userAddress: memoAddressText,
                                    memoTitle: memoTitle,
                                    memoContents: memoContents,
                                    memoShare: false,
                                    memoTagList: memoSelectedTags,
                                    memoLikeCount: 0,
                                    memoimages: memoSelectedImageItems,
                                    momocreatedAt: Date().timeIntervalSince1970)

        memoData.append(newMemo)
        print(newMemo)
    }
}
