//
//  SearchView.swift
//  MyMemory
//
//  Created by 김소혜 on 1/15/24.
//

import SwiftUI

struct SearchView: View {
    @State var searchQueryString = ""
    @StateObject var viewModel: AddressViewModel = .init()
    
    var filteredDatas: [AddressData] {
        if searchQueryString.isEmpty {
            return [] // 현재 빈 배열
        } else {
            return viewModel.addressList.filter { $0.name.localizedStandardContains(searchQueryString) }
        }
    }
    
    var body: some View  {
        ZStack {
            VStack {
                SearchBar(searchText: $searchQueryString)
                    .padding()
                
                Spacer()
                
                List(filteredDatas) { data in
                    Button {
                        
                    } label: {
                        SearchCell(name: data.name, address: data.address)
                    }
                }
                .listStyle(.plain)
            }
            .padding(.top, 16)
            
        }
        .onSubmit(of: .search) {
            print("검색 완료: \(searchQueryString)")
        }
        .onChange(of: searchQueryString) { newValue in
            // viewModel 사용 시 이곳에서 새로운 값 입력
            print("검색 입력: \(newValue)")
        }
    }
}

#Preview {
    SearchView()
}
