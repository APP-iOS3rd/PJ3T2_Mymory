import SwiftUI

struct PostViewFooter: View {
    @EnvironmentObject var viewModel: PostViewModel
    @Binding var isEdit: Bool
    var body: some View {
        ZStack {
            
            HStack {
                VStack(alignment: .leading) {
                    if let building = viewModel.memoAddressBuildingName {
                        Text(building)
                            .foregroundStyle(Color.textColor)
                            .font(.bold14)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text(viewModel.memoAddressText.isEmpty ? "현재 위치를 기준으로 자동으로 탐색합니다." : viewModel.memoAddressText)
                            .font(.caption)
                            .foregroundColor(Color.textColor)
                    } else {
                        Text(viewModel.memoAddressText.isEmpty ? "위치를 탐색 중입니다." : viewModel.memoAddressText)
                            .foregroundStyle(Color.textColor)
                            .font(.bold14)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                            .font(.caption)
                            .foregroundColor(Color.textColor)
                    }
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
                        if !isEdit {
                            await viewModel.getAddress()
                        }
                    }
                }
            }
            .padding()
            .background(Color.bgColor3)
            .border(width: 1, edges: [.top], color: Color.borderColor)
        }
    }
}
