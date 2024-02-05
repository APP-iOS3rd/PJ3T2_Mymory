import SwiftUI

struct PostViewFooter: View {
    @EnvironmentObject var viewModel: PostViewModel
    private var findCurrentLocationLocalizingText = String(localized: "현재 위치를 탐색하고 있습니다")
    
    var body: some View {
        ZStack {
            
            HStack {
                VStack(alignment: .leading) {
                    Text(viewModel.memoAddressText.isEmpty ? findCurrentLocationLocalizingText : viewModel.memoAddressText)
                        .foregroundStyle(Color.textColor)
                        .font(.bold14)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                        .font(.caption)
                        .foregroundColor(Color.textColor)
                }
                .padding(.leading)
                
                Spacer()
                
                NavigationLink {
                    // Your button action
                    ChangeLocationView()
                        .environmentObject(viewModel)
                 
                } label: {
                    Image(systemName: "arrow.circlepath")
                        .foregroundColor(.iconColor)
                }
                .padding(.trailing)
                .task {
                    if viewModel.memoAddressText.isEmpty {
                        await viewModel.getAddress()
                    }
                }
            }
            .padding()
            .background(Color.originColor)
            .border(width: 1, edges: [.top], color: Color.borderColor)
        }
    }
}
