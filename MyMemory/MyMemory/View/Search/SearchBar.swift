//
//  SearchBar.swift
//  MyMemory
//
//  Created by 김소혜 on 1/16/24.
//

import SwiftUI

struct SearchBar: View {

    @Binding var searchText: String 
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ? .darkGray : .black)
            
            TextField("구, 동, 건물명, 역 등으로 검색.", text: $searchText)
                .autocorrectionDisabled(true)
                //.foregroundColor(.black)
                .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(.accent)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            searchText = ""
                            UIApplication.shared.endEditing()
                        }
                    , alignment: .trailing
                )
                 
               
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.lightGray)
        )
        
       
    }
}
 
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
