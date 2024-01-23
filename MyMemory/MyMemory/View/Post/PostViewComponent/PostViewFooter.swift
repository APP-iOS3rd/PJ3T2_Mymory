import SwiftUI

struct PostViewFooter: View {
    @EnvironmentObject var viewModel: PostViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .clipShape(.rect(cornerRadius: 15))
                .foregroundStyle(Color.black)
                .frame(height: 65)
                .padding(.horizontal, 20)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text(viewModel.memoAddressText)
                        .foregroundStyle(.white)
                        .font(.bold14)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text("현재 위치를 기준으로 자동으로 탐색합니다.")
                        .font(.caption)
                        .foregroundColor(Color(.systemGray3))
                }
                .padding(.leading)
                
                Button {
                    // Your button action
                } label: {
                    Text("위치 재설정")
                }
                .buttonStyle(Pill(backgroundColor: Color.white, titleColor: Color.darkGray, setFont: .bold16, paddingVertical: 7))
                .padding(.trailing)
                .task {
                    await viewModel.getAddress()
                }
            }
        }
    }
}
