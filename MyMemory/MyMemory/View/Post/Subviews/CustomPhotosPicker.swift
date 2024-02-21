//
//  CustomPhotosPicker.swift
//  MyMemory
//
//  Created by 김태훈 on 2/19/24.
//

import Foundation
import SwiftUI
import PhotosUI
import Photos

struct CustomPhotosPicker: View {
    @State private var scrolledHeight: CGFloat = 0
    @State private var showsAlert: Bool = false
    @ObservedObject var viewModel: PhotosViewModel = .init()
    @Binding var selected: [PHAsset]
    
    @State var selectedValue: [PHAsset] = []
    @Environment(\.dismiss) var dismiss
    @State var maxImage = 5
    private let width = UIScreen.main.bounds.width/3
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("사진 라이브러리")
                    .font(.bold16)
                    .frame(maxWidth: .infinity)
                Spacer()
            }.padding(.vertical, 15)
                .overlay(
                    HStack {
                        Spacer()
                        Button(self.selectedValue.isEmpty ? "닫기" : "저장"){self.dismiss()}
                            .padding(.trailing, 15)
                            .font(.regular14)
                    }
                )
            ScrollView {
                LazyVGrid(columns: createGrid(), spacing: 0) {
                    ForEach(viewModel.assets.indices, id: \.self) { idx in
                        Image(uiImage: viewModel.assets[idx].image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        
                            .frame(width: width, height: width)
                            .contentShape(Rectangle())
                            .clipped()
                            .onTapGesture {
                                if let first = selectedValue.firstIndex(of: viewModel.assets[idx].asset) {
                                    selectedValue.remove(at: first)
                                } else {
                                    if selectedValue.count >= maxImage {
                                        self.showsAlert.toggle()
                                    } else {
                                        selectedValue.append(viewModel.assets[idx].asset)
                                    }
                                }
                            }
                            .overlay(
                                VStack {
                                    HStack {
                                        Spacer()
                                        Image(systemName: selectedValue.contains(viewModel.assets[idx].asset) ? "circle.fill" : "circle")
                                            .padding([.top,.trailing], 10)
                                        
                                    }
                                    Spacer()
                                }
                            )
                            
                    }
                    
                }
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                    
                        scrolledHeight = geometry.frame(in: .global).height
                    }
                    .onChange(of: geometry.frame(in: .global).minY) {oldValue, newValue in
                        if newValue * -1 > geometry.frame(in: .global).height / 2 {
                            if viewModel.pagenate {
                                viewModel.pagenate = false
                                print("높이는 :\(geometry.frame(in: .global).height)")
                                viewModel.loadMorePhotos()
                            }
                        }
                    }
                })
            }.scrollIndicators(.hidden)

        }
        .moahAlert(isPresented: $showsAlert) {
            MoahAlertView(title: "사진은 \(self.maxImage)개 까지만\n선택 가능합니다!",firstBtn: .init(type: .CONFIRM, isPresented: $showsAlert, action: {
                
            }))
        }
        .onAppear{
            self.selectedValue = self.selected
            
        }
        .onDisappear{
            self.selected = self.selectedValue
        }
    }
    func createGrid() -> [GridItem] {
        let columns = [
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0),
            GridItem(.flexible(), spacing: 0)
        ]
        return columns
    }
    
}
